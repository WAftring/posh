<#
.SYNOPSIS
    Write nested HashTable to output

.DESCRIPTION
    The usual HashTable output function do not display nested hashtables.
#>
function Write-HashTable { 
    param(
        # ([ordered]) Hashtable to display
        $HashTable,

        # List of keys to exclude - values are replaced with '*****'.
        [string[]] $Exclude,

        [Parameter(DontShow = $true)]
        [int] $Indent
    ) 

    $HashTable.Keys | % { $max_len=0 } { $l = $_.ToString().Length; if ($l -gt $max_len) { $max_len = $l } }
    foreach ($kv in $HashTable.GetEnumerator()) {
        $is_HashTable = ($kv.Value -is [HashTable]) -or ($kv.Value -is [System.Collections.Specialized.OrderedDictionary])
        if ($is_HashTable) { 
            $val = Write-HashTable $kv.Value -Exclude $Exclude -Indent ($Indent + 2) 
        } 
        elseif ($kv.Value -is [Array] ) {
            $v = $kv.Value[0..3] -join ', '
            $v += if ($kv.Value.Count -gt 5) { '...' }
            $val = "{" + $v + "}"
        }
        else { 
            $val = $kv.Value.ToString()
            if ($val.IndexOf("`n") -ne -1) {
                $val = $val -split "`n"
                $val = $val[0] + ($val[1..5] | % { "`n" + ' '*($max_len+3+$Indent) + $_})
            }
        }            
        
        if ($kv.Key -in $Exclude) { 
            $rval = '*****'
            $val = if ($is_HashTable) { $val -replace '(?<=: ).+', $rval }  else  { $rval }
        }
        $key = ' ' *$Indent + $kv.Key.PadRight($max_len) + ' : ' 
        if ($is_HashTable) { $key; $val } else { $key + $val }
    }
}