# TODO

## Transaction safety in `Cache`

Cache can retain ids for rows that get rolled back. Poisoned entries cause
FK violations and `RecordNotFound` on subsequent use.

### Poisoning paths

- **`Cache#create` / `Cache#create!`** (`lib/lookup_by/cache.rb:81-91`)
  `cache_write` fires immediately after insert, before the enclosing
  transaction commits. Outer rollback leaves a phantom id in `@cache` /
  `@reverse`.
- **`Cache#fetch` repeat-read** (`lib/lookup_by/cache.rb:100-117`)
  First `fetch` inserts via `db_write` (not cached). A second `fetch` for
  the same value within the same doomed transaction sees its own write via
  `db_read`, then `cache_write` on line 108 stores the id. Rollback leaves
  it stranded.

### Fix options

- [ ] Defer `cache_write` until `after_commit`. Register a transaction
      callback on the created record so the cache is only populated once
      the write is durable. Drop the entry on `after_rollback`.
- [ ] Alternatively, gate `cache_write` on
      `@klass.connection.open_transactions.zero?` and skip caching when
      inside a transaction — simpler but loses the warm-cache benefit for
      in-tx reads.
- [ ] Add specs covering: `create` inside a rolling-back tx, `fetch`
      repeat-read inside a rolling-back tx, nested `requires_new`
      savepoint rollback with outer commit (should NOT drop the entry).

## Transaction safety in `db_write`

`Cache#db_write` (`lib/lookup_by/cache.rb:232-242`) has a few rough edges
when called from inside nested transactions.

- [ ] **Aborted outer tx.** If the enclosing transaction is already in an
      aborted state (prior unrescued error), the `SAVEPOINT` issued by
      `requires_new: true` raises `PG::InFailedSqlTransaction`, which is
      not caught by the current `rescue`. Decide whether to let it
      propagate (current behavior) or wrap with a clearer error.
- [ ] **Isolation-level re-read miss.** Under REPEATABLE READ, the
      fallback `db_read(value)` on line 241 cannot see a row a concurrent
      transaction just committed. `db_write` returns nil; `fetch` then
      returns nil and the caller NPEs. Consider documenting the READ
      COMMITTED requirement, or retrying on a fresh connection.
- [ ] **Dead `PG::UniqueViolation` rescue clause.** ActiveRecord wraps
      `PG::UniqueViolation` as `ActiveRecord::RecordNotUnique` before it
      reaches user code, so the `PG::UniqueViolation` arm of the rescue
      on line 240 never fires. Remove it.
