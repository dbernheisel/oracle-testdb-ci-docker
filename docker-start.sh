source wait-for-db.sh
if [ "${BUNDLE_EXEC:+set}" = set ]; then bundle exec $BUNDLE_EXEC; fi
RAILS_ENV="${RAILS_ENV:-development}"
tail -f log/$RAILS_ENV.log log/delayed_job.log &
childPID=$!
wait $childPID
