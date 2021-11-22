function Get-ChildItemModern {
  Begin {
    function _Format-DateTime {
      Param (
        [string]$dt
      )
      Begin {
        $m = 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
        $d = $dt.split()[0].split('/')
        $t = $dt.split()[1].split(':')
      }
      Process{
        if ($d[1].StartsWith('0')) { $dt = ' ' } else { $dt = '' }
        $dt += [string][int32]$d[1] + ' ' + $m[$d[0] - 1] + ' '
        if ($d[2] -eq (Get-Date -f yyyy)) {
          $dt += $t[0] + ':' + $t[1]
        } else {
          $dt += ' ' + $d[2]
        }
        return $dt
      }
      End{}
    }
    Function _Format-Bytes {
      Param (
        [float]$number
      )
      Begin{
        $sizes = 'KB','MB','GB','TB','PB'
      }
      Process {
        for ($i = 0;$i -lt $sizes.count; $i++){
          if ($number -lt [int32]"1$($sizes[$i])"){
            if ($i -eq 0){
              return "$number  B"
            } else {
              $num = $number / [int32]"1$($sizes[$i-1])"
              $num = "{0:N0}" -f $num
              return "$num $($sizes[$i-1])"
            }
          }
        }
      }
    }
    function _Color-Table {
      Param (
        [string[]]$table
      )
      Begin {
        $table = $table.split("`n")
        $icons = @{'py'='  ','DarkYellow';'txt'='  ', 'Gray';'folder'='  ', 'Blue';'js'='  ', 'Gray';'md'='  ', 'Gray';'json'='  ', 'Gray'; 'file'='  ', 'Gray'; 'ts'='  ', 'DarkBlue'; '7z'='  ', 'Gray';'zip'='  ', 'Gray'; 'rar'='  ', 'Gray';}
        function _Draw-Icon {
          Param (
            [string[]]$ic
          )
          Begin {
            if ($ic -eq $null) { $ic = $icons['file'] } 
          }
          Process {
            Write-Host $ic[0] -ForegroundColor $ic[1] -NoNewline
          }
        }
        function _Check-HM {
          Param (
            [string[]]$mc
          )
          Begin {
            if ($mc[2] -eq $null) { $mc += $mc[0] }
          }
          Process {
            if ($mc[0] -eq '-') {
              Write-Host $mc[2] -NoNewline
            } else {
              Write-Host $mc[2] -ForegroundColor $mc[1] -NoNewline
            }
          }
        }
      }
      Process {
        foreach ($x in $table) {
          _Check-HM ($x.substring(0, 1), "Gray")
          _Check-HM ($x.substring(1, 1), "Gray")
          _Check-HM ($x.substring(2, 1), "Yellow")
          _Check-HM ($x.substring(3, 1), "Green")
          _Check-HM ($x.substring(4, 1), "Purple")
          Write-Host $x.substring(5, 5) -ForegroundColor Gray -NoNewline
          _Check-HM ($x.substring(11, 1), "Green", $x.substring(10, 2))
          Write-Host $x.substring(12, 15) -ForegroundColor Blue -NoNewline
          if ($x.substring(0,1) -eq 'd') {
            _Draw-Icon $icons['folder']
            Write-Host $x.substring(27) -ForegroundColor White 
          } elseif ($x.split('.').count -lt 2) {
            _Draw-Icon $icons['file']
            Write-Host $x.substring(27)
          } else {
            _Draw-Icon $icons[$x.split('.')[1].trim()]
            Write-Host $x.substring(27)
          }
        }
      }
    }
  }
  Process {
    _Color-Table (
      Get-ChildItem $Args |
      Format-Table -HideTableHeaders Mode,
        #@{N='Owner';E={(Get-Acl $_.FullName).Owner}},
        @{N='Length';E={if($_.Mode.StartsWith('d')) {'-'} else {_Format-Bytes $_.Length}};A='Right'},
        @{N='LastWriteTime';E={_Format-DateTime $_.LastWriteTime}},
        @{N='Name';E={if($_.Mode.StartsWith('d')) {$_.Name + '/'} else {$_.Name}}} |
      Out-String
    ).Trim()
  }
}

New-Alias ll Get-ChildItemModern
