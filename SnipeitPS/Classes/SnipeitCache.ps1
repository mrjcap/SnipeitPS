class SnipeitCacheEntry {
    [DateTime]$ExpiresAt
    [object]$Value

    SnipeitCacheEntry([object]$value, [int]$ttlSeconds) {
        $this.Value = $value
        $this.ExpiresAt = [DateTime]::UtcNow.AddSeconds($ttlSeconds)
    }

    [bool] IsExpired() {
        return [DateTime]::UtcNow -ge $this.ExpiresAt
    }
}

class SnipeitCache {
    static [hashtable]$Store = [hashtable]::Synchronized(@{})
    static [int]$MaxCapacity = 500

    static [void] PruneExpired() {
        $keysToRemove = [System.Collections.Generic.List[string]]::new()
        [System.Threading.Monitor]::Enter([SnipeitCache]::Store.SyncRoot)
        try {
            $now = [DateTime]::UtcNow
            foreach ($key in [SnipeitCache]::Store.Keys) {
                $entry = [SnipeitCache]::Store[$key]
                if ($null -eq $entry -or ($now -ge $entry.ExpiresAt)) {
                    $keysToRemove.Add($key)
                }
            }
            foreach ($k in $keysToRemove) {
                [SnipeitCache]::Store.Remove($k)
            }
            # If still over capacity, enforce FIFO eviction
            if ([SnipeitCache]::Store.Count -ge [SnipeitCache]::MaxCapacity) {
                $excess = [SnipeitCache]::Store.Count - [SnipeitCache]::MaxCapacity + 10
                $evictKeys = [System.Collections.Generic.List[string]]::new()
                foreach ($k in [SnipeitCache]::Store.Keys) {
                    $evictKeys.Add($k)
                    if ($evictKeys.Count -ge $excess) { break }
                }
                foreach ($k in $evictKeys) {
                    [SnipeitCache]::Store.Remove($k)
                }
            }
        } finally {
            [System.Threading.Monitor]::Exit([SnipeitCache]::Store.SyncRoot)
        }
    }

    static [object] GetOrAdd([string]$key, [int]$ttlSeconds, [scriptblock]$factory) {
        [System.Threading.Monitor]::Enter([SnipeitCache]::Store.SyncRoot)
        try {
            if ([SnipeitCache]::Store.ContainsKey($key)) {
                $entry = [SnipeitCache]::Store[$key]
                if ($null -ne $entry -and ([DateTime]::UtcNow -lt $entry.ExpiresAt)) {
                    return $entry.Value
                }
            }

            $val = & $factory
            # PS5 cannot marshal AutomationNull from an object-returning class method.
            if ($null -eq $val) {
                return $null
            }
            if ([SnipeitCache]::Store.Count -ge [SnipeitCache]::MaxCapacity) {
                [SnipeitCache]::PruneExpired()
            }
            [SnipeitCache]::Store[$key] = [SnipeitCacheEntry]::new($val, $ttlSeconds)
            return $val
        } finally {
            [System.Threading.Monitor]::Exit([SnipeitCache]::Store.SyncRoot)
        }
    }

    static [void] Remove([string]$key) {
        [System.Threading.Monitor]::Enter([SnipeitCache]::Store.SyncRoot)
        try {
            if ([SnipeitCache]::Store.ContainsKey($key)) {
                [SnipeitCache]::Store.Remove($key)
            }
        } finally {
            [System.Threading.Monitor]::Exit([SnipeitCache]::Store.SyncRoot)
        }
    }

    static [void] Clear() {
        [System.Threading.Monitor]::Enter([SnipeitCache]::Store.SyncRoot)
        try {
            [SnipeitCache]::Store.Clear()
        } finally {
            [System.Threading.Monitor]::Exit([SnipeitCache]::Store.SyncRoot)
        }
    }
}
