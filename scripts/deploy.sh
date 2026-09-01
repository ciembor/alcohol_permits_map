#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:?REMOTE_HOST is required, for example ciembor@example.org}"
REMOTE_DIR="${REMOTE_DIR:-/home/ciembor/alcohol_permits_map}"
SERVICE_NAME="${SERVICE_NAME:-alcohol-permits-map}"
IMAGE_NAME="${IMAGE_NAME:-localhost/alcohol-permits-map:latest}"
PUBLIC_BASE_URL="${PUBLIC_BASE_URL:-}"
HEALTHCHECK_ATTEMPTS="${HEALTHCHECK_ATTEMPTS:-30}"
HEALTHCHECK_SLEEP_SECONDS="${HEALTHCHECK_SLEEP_SECONDS:-2}"
WARM_REPORT_CACHE="${WARM_REPORT_CACHE:-1}"
WARM_REPORT_CACHE_MAX_TIME="${WARM_REPORT_CACHE_MAX_TIME:-90}"
WARM_REPORT_CACHE_ATTEMPTS="${WARM_REPORT_CACHE_ATTEMPTS:-3}"
DEPLOY_ACTION="${1:-${DEPLOY_ACTION:-deploy}}"
RELEASE_NAME="${RELEASE_NAME:-$(git rev-parse --short HEAD)}"
IMAGE_REPOSITORY="${IMAGE_NAME%:*}"
PREVIOUS_IMAGE_NAME="${PREVIOUS_IMAGE_NAME:-${IMAGE_REPOSITORY}:previous}"
ROLLBACK_CANDIDATE_IMAGE_NAME="${ROLLBACK_CANDIDATE_IMAGE_NAME:-${IMAGE_REPOSITORY}:rollback-candidate}"
RELEASE_IMAGE_NAME="${RELEASE_IMAGE_NAME:-${IMAGE_REPOSITORY}:${RELEASE_NAME}}"

usage() {
  echo "usage: scripts/deploy.sh [deploy|rollback]" >&2
  exit 64
}

case "$DEPLOY_ACTION" in
  deploy|rollback)
    ;;
  *)
    usage
    ;;
esac

sync_checkout() {
  git archive --format=tar HEAD -- \
    .dockerignore \
    .ruby-version \
    Dockerfile \
    Gemfile \
    Gemfile.lock \
    Rakefile \
    app \
    bin \
    config \
    config.ru \
    db/migrate \
    db/schema.rb \
    db/seeds.rb \
    deploy \
    lib \
    public \
    scripts \
    vendor/data/sim \
    package.json | ssh "${REMOTE_HOST}" \
      "mkdir -p '${REMOTE_DIR}' && tar -xf - -C '${REMOTE_DIR}'"
}

if [ "$DEPLOY_ACTION" = "deploy" ]; then
  sync_checkout
fi

ssh "${REMOTE_HOST}" \
  "REMOTE_DIR='${REMOTE_DIR}' \
  SERVICE_NAME='${SERVICE_NAME}' \
  IMAGE_NAME='${IMAGE_NAME}' \
  PREVIOUS_IMAGE_NAME='${PREVIOUS_IMAGE_NAME}' \
  ROLLBACK_CANDIDATE_IMAGE_NAME='${ROLLBACK_CANDIDATE_IMAGE_NAME}' \
  RELEASE_IMAGE_NAME='${RELEASE_IMAGE_NAME}' \
  RELEASE_NAME='${RELEASE_NAME}' \
  PUBLIC_BASE_URL='${PUBLIC_BASE_URL}' \
  HEALTHCHECK_ATTEMPTS='${HEALTHCHECK_ATTEMPTS}' \
  HEALTHCHECK_SLEEP_SECONDS='${HEALTHCHECK_SLEEP_SECONDS}' \
  WARM_REPORT_CACHE='${WARM_REPORT_CACHE}' \
  WARM_REPORT_CACHE_MAX_TIME='${WARM_REPORT_CACHE_MAX_TIME}' \
  WARM_REPORT_CACHE_ATTEMPTS='${WARM_REPORT_CACHE_ATTEMPTS}' \
  bash -s -- '${DEPLOY_ACTION}'" <<'REMOTE'
set -euo pipefail

action="$1"
deploy_state_dir="${REMOTE_DIR}/tmp/deploy"
current_release_file="${deploy_state_dir}/current-release"
previous_release_file="${deploy_state_dir}/previous-release"

mkdir -p "$deploy_state_dir" "${REMOTE_DIR}/db" "${REMOTE_DIR}/log" "${REMOTE_DIR}/storage"

image_exists() {
  sudo podman image inspect "$1" >/dev/null 2>&1
}

restart_app_service() {
  sudo systemctl restart "${SERVICE_NAME}"
}

write_cache_version() {
  local cache_version="$1"
  local env_file="${REMOTE_DIR}/.env.local"
  touch "$env_file"
  if grep -q '^ALKOMAPA_DATA_CACHE_VERSION=' "$env_file"; then
    sed -i "s/^ALKOMAPA_DATA_CACHE_VERSION=.*/ALKOMAPA_DATA_CACHE_VERSION=${cache_version}/" "$env_file"
  else
    printf '\nALKOMAPA_DATA_CACHE_VERSION=%s\n' "${cache_version}" >> "$env_file"
  fi
}

restore_previous_release() {
  if image_exists "${PREVIOUS_IMAGE_NAME}"; then
    sudo podman tag "${PREVIOUS_IMAGE_NAME}" "${IMAGE_NAME}"
  fi
  if [ -n "${previous_release}" ]; then
    write_cache_version "${previous_release}"
  fi
  if image_exists "${PREVIOUS_IMAGE_NAME}"; then
    restart_app_service
    wait_for_smoke_checks || true
  fi
}

run_release_container() {
  local container_name="$1"
  shift

  sudo podman rm -f "${container_name}" >/dev/null 2>&1 || true
  sudo podman run --rm --name="${container_name}" \
    --user=1000:1000 \
    --read-only \
    --memory=900m --memory-swap=900m --memory-reservation=384m \
    --cpus=0.75 --pids-limit=192 \
    --env-file "${REMOTE_DIR}/.env.local" \
    -e ALKOMAPA_DATA_CACHE_VERSION="${RELEASE_NAME}" \
    -e WARM_REPORT_AT="${WARM_REPORT_AT:-}" \
    -e RAILS_ENV=production \
    -e RAILS_LOG_TO_STDOUT=1 \
    -e RAILS_SERVE_STATIC_FILES=1 \
    -v "${REMOTE_DIR}/db:/app/db:rw" \
    -v "${REMOTE_DIR}/log:/app/log:rw" \
    -v "${REMOTE_DIR}/tmp:/app/tmp:rw" \
    -v "${REMOTE_DIR}/storage:/app/storage:rw" \
    "${RELEASE_IMAGE_NAME}" \
    "$@"
}

run_database_migrations() {
  run_release_container "${SERVICE_NAME}-migrate" bundle exec rails db:migrate
}

smoke_check_once() {
  curl --connect-timeout 2 --max-time 5 -fsSL -o /dev/null "http://127.0.0.1:9294/healthz"
  if [ -n "${PUBLIC_BASE_URL}" ]; then
    curl --connect-timeout 2 --max-time 5 -fsSL -o /dev/null "${PUBLIC_BASE_URL%/}/healthz"
  fi
}

wait_for_smoke_checks() {
  local attempt
  for attempt in $(seq 1 "${HEALTHCHECK_ATTEMPTS}"); do
    if smoke_check_once; then
      return 0
    fi
    sleep "${HEALTHCHECK_SLEEP_SECONDS}"
  done

  return 1
}

wait_for_app_container() {
  local attempt
  local running

  for attempt in $(seq 1 "${HEALTHCHECK_ATTEMPTS}"); do
    running="$(sudo podman inspect --format '{{.State.Running}}' "${SERVICE_NAME}" 2>/dev/null || true)"
    if [ "${running}" = "true" ]; then
      return 0
    fi
    sleep "${HEALTHCHECK_SLEEP_SECONDS}"
  done

  return 1
}

cleanup_project_containers() {
  local container_name
  local running

  sudo podman ps -a --format '{{.Names}}' | while IFS= read -r container_name; do
    case "${container_name}" in
      "${SERVICE_NAME}")
        ;;
      "${SERVICE_NAME}-"*)
        running="$(sudo podman inspect --format '{{.State.Running}}' "${container_name}" 2>/dev/null || true)"
        if [ "${running}" != "true" ]; then
          sudo podman rm "${container_name}" >/dev/null 2>&1 || true
        fi
        ;;
    esac
  done
}

cleanup_project_images() {
  local image
  local keep_image
  local image_repository="${IMAGE_NAME%:*}"

  sudo podman images --format '{{.Repository}}:{{.Tag}}' | while IFS= read -r image; do
    case "${image}" in
      "${image_repository}:"*)
        for keep_image in "${IMAGE_NAME}" "${PREVIOUS_IMAGE_NAME}" "$@"; do
          if [ "${image}" = "${keep_image}" ]; then
            continue 2
          fi
        done
        sudo podman image rm "${image}" >/dev/null 2>&1 || true
        ;;
    esac
  done
}

cleanup_project_podman_artifacts() {
  cleanup_project_containers
  cleanup_project_images "$@"
}

assert_secret_key_base() {
  local env_file="${REMOTE_DIR}/.env.local"
  local secret_key_base_line=""
  local secret_key_base=""

  if [ -f "$env_file" ]; then
    secret_key_base_line="$(grep -m 1 '^SECRET_KEY_BASE=' "$env_file" || true)"
  fi
  secret_key_base="${secret_key_base_line#SECRET_KEY_BASE=}"

  if [ "${#secret_key_base}" -ge 64 ]; then
    return 0
  fi

  echo "SECRET_KEY_BASE in ${env_file} must be at least 64 characters before deploy." >&2
  echo "Generate one with: ruby -rsecurerandom -e 'puts SecureRandom.hex(64)'" >&2
  exit 78
}

install_units() {
  cd "${REMOTE_DIR}"
  sudo install -m 0644 "deploy/${SERVICE_NAME}.service" "/etc/systemd/system/${SERVICE_NAME}.service"
  sudo systemctl daemon-reload
  sudo systemctl enable "${SERVICE_NAME}.service"
}

write_release_env() {
  write_cache_version "${RELEASE_NAME}"
}

warm_report_cache() {
  if [ "${WARM_REPORT_CACHE}" != "1" ]; then
    return 0
  fi

  echo "Warming map report cache for release ${RELEASE_NAME}"

  run_release_container "${SERVICE_NAME}-reports" bundle exec rails runner \
    'ActiveRecord::Base.logger = nil; puts AlcoholLicense.where.not(reported_at: nil).distinct.order(:reported_at).pluck(:reported_at).map { |report| report.utc.iso8601 }' |
    grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' |
    while IFS= read -r report_at; do
      [ -n "${report_at}" ] || continue
      printf '  %s... ' "${report_at}"
      local attempt=1
      while ! WARM_REPORT_AT="${report_at}" run_release_container "${SERVICE_NAME}-report-cache" bundle exec rails runner '
        ActiveRecord::Base.logger = nil
        requested_at = Time.zone.parse(ENV.fetch("WARM_REPORT_AT")).utc
        controller = MapsController.new
        report = controller.send(:available_reports).find { |available_report| available_report.to_i == requested_at.to_i }
        raise "Report not found: #{requested_at.iso8601}" unless report
        path = controller.send(:report_cache_path, report)
        unless File.file?(path)
          json = JSON.generate(controller.send(:report_payload, report))
          controller.send(:write_report_cache, path, json)
        end
      '; do
        if [ "${attempt}" -ge "${WARM_REPORT_CACHE_ATTEMPTS}" ]; then
          echo "failed"
          return 1
        fi

        printf 'retry %s... ' "${attempt}"
        attempt=$((attempt + 1))
        sleep 2
      done
      printf 'ok\n'
    done
}

compress_report_cache() {
  if [ "${WARM_REPORT_CACHE}" != "1" ]; then
    return 0
  fi

  local cache_dir="${REMOTE_DIR}/storage/prod_alkomapa_data_local/data/cache/${RELEASE_NAME}"
  if [ ! -d "${cache_dir}" ]; then
    return 0
  fi

  echo "Compressing map report cache for release ${RELEASE_NAME}"
  find "${cache_dir}" -type f -name '*.json' -exec gzip -kf {} +
}

deploy_release() {
  local previous_release=""

  assert_secret_key_base
  install_units

  if image_exists "${IMAGE_NAME}"; then
    sudo podman tag "${IMAGE_NAME}" "${PREVIOUS_IMAGE_NAME}"
    if [ -f "${current_release_file}" ]; then
      previous_release="$(cat "${current_release_file}")"
    fi
  fi

  cd "${REMOTE_DIR}"
  sudo podman build -t "${RELEASE_IMAGE_NAME}" .
  run_database_migrations

  if ! warm_report_cache; then
    echo "Report cache warm-up failed; keeping previous image active" >&2
    sudo systemctl status "${SERVICE_NAME}" --no-pager || true
    exit 1
  fi

  compress_report_cache
  write_release_env
  sudo podman tag "${RELEASE_IMAGE_NAME}" "${IMAGE_NAME}"
  restart_app_service

  if ! wait_for_smoke_checks; then
    echo "Deploy smoke checks failed; restoring previous image" >&2
    restore_previous_release
    sudo systemctl status "${SERVICE_NAME}" --no-pager || true
    exit 1
  fi

  if ! wait_for_app_container; then
    echo "App container did not become visible after restart; restoring previous image" >&2
    restore_previous_release
    sudo systemctl status "${SERVICE_NAME}" --no-pager || true
    exit 1
  fi

  if ! wait_for_smoke_checks; then
    echo "App failed smoke checks after report cache warm-up; restoring previous image" >&2
    restore_previous_release
    sudo systemctl status "${SERVICE_NAME}" --no-pager || true
    exit 1
  fi

  printf '%s\n' "${RELEASE_NAME}" > "${current_release_file}"
  if [ -n "${previous_release}" ]; then
    printf '%s\n' "${previous_release}" > "${previous_release_file}"
  else
    rm -f "${previous_release_file}"
  fi
  cleanup_project_podman_artifacts "${RELEASE_IMAGE_NAME}"
}

rollback_release() {
  local current_release="unknown"
  local previous_release="unknown"

  assert_secret_key_base

  if ! image_exists "${PREVIOUS_IMAGE_NAME}"; then
    echo "No previous image available for rollback" >&2
    exit 1
  fi

  if [ -f "${current_release_file}" ]; then
    current_release="$(cat "${current_release_file}")"
  fi
  if [ -f "${previous_release_file}" ]; then
    previous_release="$(cat "${previous_release_file}")"
  fi

  sudo podman tag "${IMAGE_NAME}" "${ROLLBACK_CANDIDATE_IMAGE_NAME}"
  sudo podman tag "${PREVIOUS_IMAGE_NAME}" "${IMAGE_NAME}"
  restart_app_service

  if ! wait_for_smoke_checks; then
    echo "Rollback smoke checks failed; restoring the pre-rollback image" >&2
    sudo podman tag "${ROLLBACK_CANDIDATE_IMAGE_NAME}" "${IMAGE_NAME}"
    restart_app_service
    wait_for_smoke_checks || true
    sudo systemctl status "${SERVICE_NAME}" --no-pager || true
    exit 1
  fi

  sudo podman tag "${ROLLBACK_CANDIDATE_IMAGE_NAME}" "${PREVIOUS_IMAGE_NAME}"
  printf '%s\n' "${previous_release}" > "${current_release_file}"
  printf '%s\n' "${current_release}" > "${previous_release_file}"
  sudo podman image rm "${ROLLBACK_CANDIDATE_IMAGE_NAME}" >/dev/null 2>&1 || true
  cleanup_project_podman_artifacts
}

case "${action}" in
  deploy)
    deploy_release
    ;;
  rollback)
    rollback_release
    ;;
  *)
    echo "Unsupported deploy action: ${action}" >&2
    exit 64
    ;;
esac

sudo systemctl status "${SERVICE_NAME}" --no-pager || true
REMOTE
