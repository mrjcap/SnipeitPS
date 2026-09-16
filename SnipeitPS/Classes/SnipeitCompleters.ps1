class SnipeitCompleterHelper {
    static [System.Collections.Generic.List[System.Management.Automation.CompletionResult]] Complete(
        [string]$cacheKey,
        [int]$ttl,
        [scriptblock]$fetcher,
        [string]$wordToComplete) {
        return [SnipeitCompleterHelper]::Complete($cacheKey, $ttl, $fetcher, $wordToComplete, $null, $null)
    }

    static [System.Collections.Generic.List[System.Management.Automation.CompletionResult]] Complete(
        [string]$cacheKey,
        [int]$ttl,
        [scriptblock]$fetcher,
        [string]$wordToComplete,
        [scriptblock]$extraFilter,
        [scriptblock]$labelBuilder) {
        $module = Get-Module -Name SnipeitPS
        if ($null -ne $module) {
            $fetcher = $module.NewBoundScriptBlock($fetcher)
        }
        $items = [SnipeitCache]::GetOrAdd($cacheKey, $ttl, $fetcher)
        $results = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        if ($null -ne $items) {
            foreach ($item in $items) {
                $id = [string]$item.id
                $name = [string]$item.name
                $matched = ($name -like "*$wordToComplete*" -or $id -like "$wordToComplete*")
                if (-not $matched -and $null -ne $extraFilter) {
                    $matched = & $extraFilter $item $wordToComplete
                }
                if ($matched) {
                    $label = if ($null -ne $labelBuilder) { & $labelBuilder $item } else { $name }
                    $results.Add([System.Management.Automation.CompletionResult]::new(
                        $id,
                        "$id ($label)",
                        [System.Management.Automation.CompletionResultType]::ParameterValue,
                        "$label (ID: $id)"
                    ))
                }
            }
        }
        return $results
    }
}

class SnipeitModelCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Models', 300, { try { Get-SnipeitModel -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete)
    }
}

class SnipeitStatusCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Statuses', 300, { try { Get-SnipeitStatus -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete, $null, {
            param($i) if ($i.type) { "$($i.name) [$($i.type)]" } else { [string]$i.name }
        })
    }
}

class SnipeitCategoryCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Categories', 300, { try { Get-SnipeitCategory -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete, $null, {
            param($i) if ($i.category_type) { "$($i.name) [$($i.category_type)]" } else { [string]$i.name }
        })
    }
}

class SnipeitLocationCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Locations', 300, { try { Get-SnipeitLocation -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete)
    }
}

class SnipeitCompanyCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Companies', 300, { try { Get-SnipeitCompany -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete)
    }
}

class SnipeitSupplierCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Suppliers', 300, { try { Get-SnipeitSupplier -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete)
    }
}

class SnipeitDepartmentCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Departments', 300, { try { Get-SnipeitDepartment -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete)
    }
}

class SnipeitManufacturerCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Manufacturers', 300, { try { Get-SnipeitManufacturer -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete)
    }
}

class SnipeitUserCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string]$commandName, [string]$parameterName, [string]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst, [System.Collections.IDictionary]$fakeBoundParameters) {
        return [SnipeitCompleterHelper]::Complete('Users', 300, { try { Get-SnipeitUser -all -ErrorAction SilentlyContinue } catch { @() } }, $wordToComplete, {
            param($i, $w) [string]$i.username -like "*$w*"
        }, {
            param($i) if ($i.username) { "$($i.name) ($($i.username))" } else { [string]$i.name }
        })
    }
}

