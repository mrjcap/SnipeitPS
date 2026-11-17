export const title = "Connection-bound model completion (bounded, sequential)";
export function state(s) {
  return `${s.event}: default=${s.connection} cache=${s.owner}/${s.fresh ? 'fresh' : 'expired'} request=${s.requested} shown=${s.shown} n=${s.operations}`;
}
export function step(_action, _before, after) { return after.event; }
