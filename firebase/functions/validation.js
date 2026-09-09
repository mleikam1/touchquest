'use strict';
exports.plausible = (run) => Number.isInteger(run.rawTaps) && run.rawTaps >= 0 && run.rawTaps <= 1000000
  && Number.isInteger(run.durationMs) && run.durationMs > 0 && run.durationMs <= 86400000
  && run.rawTaps <= run.durationMs / 1000 * 25 + 10
  && Number.isInteger(run.score) && run.score >= run.rawTaps && run.score <= run.rawTaps * 3
  && ['casual', 'campaign', 'chaos'].includes(run.mode) && [0, 1].includes(run.reviveCount);
