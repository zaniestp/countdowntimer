<#
.SYNOPSIS
A reusable, resizable countdown timer with a stable, hideable interface.

.DESCRIPTION
This script launches an input form to set a countdown. The countdown window
features a stable horizontal layout, hideable side panels, and an auto-scaling font.

.NOTES
To use:
1. Save this code as a PowerShell script file (e.g., countdown_timer.ps1).
2. (Optional) Create a 'config.txt' file for window appearance.
3. (Optional) Place a 'default.wav' file in the same folder for a custom sound.
4. Run the script: .\countdown_timer.ps1
#>

#-----------------------------------------------------------------------
# CONFIGURATION - Change these values to customize the timer
#-----------------------------------------------------------------------

# Set the path to the icon file (.ico) for the window.
$iconFile = "C:\APPS\Counter\favicon.ico" # Example path, change as needed

# --- Sound File Logic ---
$defaultSoundFile = Join-Path $PSScriptRoot "default.wav"
if (Test-Path $defaultSoundFile) {
    $soundFile = $defaultSoundFile
}
else {
    $soundFile = "C:\Windows\Media\Alarm02.wav"
}

#-----------------------------------------------------------------------
# SCRIPT LOGIC - No need to edit below this line
#-----------------------------------------------------------------------

# 1. Load required .NET assemblies.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 2. INITIALIZE STATE VARIABLES (OUTSIDE THE LOOP)
$script:exitScript = $false
$Minutes = 0
$Seconds = 10
$PlaySoundChecked = $true

# 3. START THE MAIN APPLICATION LOOP
while (-not $script:exitScript) {

    $startCountdown = $false

    #-------------------------------------------------------------------
    # CREATE AND SHOW THE INPUT FORM
    #-------------------------------------------------------------------
    $inputForm = New-Object System.Windows.Forms.Form
    $inputForm.Text = "Set Timer"
    $inputForm.Size = New-Object System.Drawing.Size(300, 200)
    $inputForm.StartPosition = 'CenterScreen'
    $inputForm.FormBorderStyle = 'FixedDialog'
    $inputForm.MaximizeBox = $false
    $inputForm.MinimizeBox = $false

    # Create controls for the input form
    $minutesLabel = New-Object System.Windows.Forms.Label
    $minutesLabel.Text = "Minutes:"
    $minutesLabel.Location = New-Object System.Drawing.Point(20, 23)
    $minutesLabel.Size = New-Object System.Drawing.Size(60, 20)
    $minutesTextBox = New-Object System.Windows.Forms.TextBox
    $minutesTextBox.Text = $Minutes
    $minutesTextBox.Location = New-Object System.Drawing.Point(85, 20)
    $minutesTextBox.Size = New-Object System.Drawing.Size(175, 20)
    $secondsLabel = New-Object System.Windows.Forms.Label
    $secondsLabel.Text = "Seconds:"
    $secondsLabel.Location = New-Object System.Drawing.Point(20, 53)
    $secondsLabel.Size = New-Object System.Drawing.Size(60, 20)
    $secondsTextBox = New-Object System.Windows.Forms.TextBox
    $secondsTextBox.Text = $Seconds
    $secondsTextBox.Location = New-Object System.Drawing.Point(85, 50)
    $secondsTextBox.Size = New-Object System.Drawing.Size(175, 20)
    $soundCheckBox = New-Object System.Windows.Forms.CheckBox
    $soundCheckBox.Text = "Play sound on finish"
    $soundCheckBox.Checked = $PlaySoundChecked
    $soundCheckBox.Location = New-Object System.Drawing.Point(23, 85)
    $soundCheckBox.Size = New-Object System.Drawing.Size(180, 20)
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "Start"
    $startButton.Location = New-Object System.Drawing.Point(20, 120)
    $startButton.Size = New-Object System.Drawing.Size(75, 30)
    $resetButton = New-Object System.Windows.Forms.Button
    $resetButton.Text = "Reset"
    $resetButton.Location = New-Object System.Drawing.Point(105, 120)
    $resetButton.Size = New-Object System.Drawing.Size(75, 30)
    $exitButton = New-Object System.Windows.Forms.Button
    $exitButton.Text = "Exit"
    $exitButton.Location = New-Object System.Drawing.Point(190, 120)
    $exitButton.Size = New-Object System.Drawing.Size(75, 30)

    # Add event handlers for the buttons
    $startButton.Add_Click({
        $parsedMinutes = 0
        $parsedSeconds = 0
        $isMinutesValid = [int]::TryParse($minutesTextBox.Text, [ref]$parsedMinutes)
        $isSecondsValid = [int]::TryParse($secondsTextBox.Text, [ref]$parsedSeconds)
        if (-not $isMinutesValid -or -not $isSecondsValid) {
            [System.Windows.Forms.MessageBox]::Show("Please enter valid whole numbers for minutes and seconds.", "Invalid Input", "OK", "Error")
            return
        }
        if ($parsedMinutes -lt 0 -or $parsedSeconds -lt 0 -or $parsedSeconds -gt 59) {
            [System.Windows.Forms.MessageBox]::Show("Minutes must be 0 or greater.`nSeconds must be between 0 and 59.", "Invalid Range", "OK", "Error")
            return
        }
        if (($parsedMinutes + $parsedSeconds) -le 0) {
            [System.Windows.Forms.MessageBox]::Show("Total time must be greater than zero.", "Invalid Time", "OK", "Error")
            return
        }
        $script:Minutes = $parsedMinutes
        $script:Seconds = $parsedSeconds
        $script:PlaySoundChecked = $soundCheckBox.Checked
        $script:startCountdown = $true
        $inputForm.Close()
    })
    $resetButton.Add_Click({
        $minutesTextBox.Text = '0'
        $secondsTextBox.Text = '10'
        $soundCheckBox.Checked = $true
    })
    $exitButton.Add_Click({
        $creditsForm = New-Object System.Windows.Forms.Form
        $creditsForm.Text = "Credits"
        $creditsForm.Size = New-Object System.Drawing.Size(400, 200)
        $creditsForm.StartPosition = 'CenterParent'
        $creditsForm.FormBorderStyle = 'FixedDialog'
        $creditsForm.MaximizeBox = $false
        $creditsForm.MinimizeBox = $false
        $autoCloseTimer = New-Object System.Windows.Forms.Timer
        $autoCloseTimer.Interval = 15000
        $autoCloseTimer.Add_Tick({ if ($creditsForm.Visible) { $creditsForm.Close() } })
        $creditsLabel = New-Object System.Windows.Forms.Label
        $creditsLabel.Text = "Thank you for using this app.`n`nIf you like this app, please write to zanyzanzen@gmail.com to show your appreciation or feedback.`n`nThis app is co-developed with Presbyterian High School."
        $creditsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $creditsLabel.Dock = 'Fill'
        $creditsLabel.TextAlign = 'MiddleCenter'
        $closeCreditsButton = New-Object System.Windows.Forms.Button
        $closeCreditsButton.Text = "Close"
        $closeCreditsButton.Dock = 'Bottom'
        $closeCreditsButton.Height = 30
        $closeCreditsButton.Add_Click({ $creditsForm.Close() })
        $creditsForm.Add_Shown({ $autoCloseTimer.Start() })
        $creditsForm.Add_FormClosing({ $autoCloseTimer.Stop() })
        $creditsForm.Controls.AddRange(@($creditsLabel, $closeCreditsButton))
        $creditsForm.ShowDialog() | Out-Null
        $creditsForm.Dispose()
        $autoCloseTimer.Dispose()
        $script:exitScript = $true
        $inputForm.Close()
    })
    $inputForm.Controls.AddRange(@($minutesLabel, $minutesTextBox, $secondsLabel, $secondsTextBox, $soundCheckBox, $startButton, $resetButton, $exitButton))
    $inputForm.ShowDialog() | Out-Null
    $inputForm.Dispose()

    if ($startCountdown) {
        #---------------------------------------------------------------
        # CONFIGURE AND RUN THE COUNTDOWN TIMER
        #---------------------------------------------------------------
        $settings = @{ WindowWidth = 100; WindowHeight = 60; FontSize = 12 }
        $configFile = Join-Path $PSScriptRoot "config.txt" 
        if (Test-Path $configFile) {
            try {
                $userSettings = Get-Content $configFile | ConvertFrom-StringData
                if ($userSettings.ContainsKey('WindowWidth') -and $userSettings.WindowWidth -as [int]) { $settings.WindowWidth = [int]$userSettings.WindowWidth }
                if ($userSettings.ContainsKey('WindowHeight') -and $userSettings.WindowHeight -as [int]) { $settings.WindowHeight = [int]$userSettings.WindowHeight }
                if ($userSettings.ContainsKey('FontSize') -and $userSettings.FontSize -as [int]) { $settings.FontSize = [int]$userSettings.FontSize }
            }
            catch { Write-Warning "Error reading config.txt." }
        }

        $totalSeconds = ($Minutes * 60) + $Seconds
        $playSound = if ($PlaySoundChecked) { 'Y' } else { 'N' }
        $isPaused = $false
        $pendingMinutes = 0
        $arePanelsHidden = $true # Start hidden
        
        $fontGarbageCollector = New-Object System.Collections.Generic.List[System.Drawing.Font]

        $largeWidth = 280
        $smallWidth = 120
        $smallMinSize = New-Object System.Drawing.Size(80, 80)
        $largeMinSize = New-Object System.Drawing.Size(240, 80)

        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Countdown"
        $form.Size = New-Object System.Drawing.Size($smallWidth, 110)
        $form.StartPosition = 'CenterScreen'
        $form.FormBorderStyle = 'Sizable' # <-- MODIFIED: Always sizable
        $form.MaximizeBox = $true
        $form.MinimizeBox = $true
        $form.Topmost = $true
        $form.MinimumSize = $smallMinSize

        if (Test-Path $iconFile) {
            try { $form.Icon = [System.Drawing.Icon]::new($iconFile) }
            catch { Write-Warning "Failed to load icon: $iconFile." }
        }

        # --- MODIFIED LAYOUT CONTROLS START ---

        $formTable = New-Object System.Windows.Forms.TableLayoutPanel
        $formTable.Dock = 'Fill'
        $formTable.ColumnCount = 1
        $formTable.RowCount = 2
        $formTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
        $formTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 20)))

        $mainTable = New-Object System.Windows.Forms.TableLayoutPanel
        $mainTable.Dock = 'Fill'
        $mainTable.ColumnCount = 6
        $mainTable.RowCount = 1
        $mainTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 25))) # +
        $mainTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 35))) # 0
        $mainTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 25))) # -
        $mainTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) # 00:00
        $mainTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 55))) # Pause
        $mainTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 45))) # Apply
        
        $linkLabelFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::None)
        $sideLabelFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        
        $plusButton = New-Object System.Windows.Forms.Label
        $plusButton.Text = "+"
        $plusButton.Dock = 'Fill'
        $plusButton.Font = $linkLabelFont
        $plusButton.ForeColor = [System.Drawing.Color]::Blue
        $plusButton.Cursor = [System.Windows.Forms.Cursors]::Hand
        $plusButton.TextAlign = 'MiddleCenter'
        
        $pendingMinutesLabel = New-Object System.Windows.Forms.Label
        $pendingMinutesLabel.Text = "0"
        $pendingMinutesLabel.Dock = 'Fill'
        $pendingMinutesLabel.TextAlign = 'MiddleCenter'
        $pendingMinutesLabel.Font = $sideLabelFont
        
        $minusButton = New-Object System.Windows.Forms.Label
        $minusButton.Text = "-"
        $minusButton.Dock = 'Fill'
        $minusButton.Font = $linkLabelFont
        $minusButton.ForeColor = [System.Drawing.Color]::Blue
        $minusButton.Cursor = [System.Windows.Forms.Cursors]::Hand
        $minusButton.TextAlign = 'MiddleCenter'

        $label = New-Object System.Windows.Forms.Label
        $label.Font = New-Object System.Drawing.Font("Segoe UI", $settings.FontSize, [System.Drawing.FontStyle]::Bold)
        $label.Dock = 'Fill'
        $label.TextAlign = 'MiddleLeft'
        
        $pauseButton = New-Object System.Windows.Forms.Label
        $pauseButton.Text = "Pause"
        $pauseButton.Dock = 'Fill'
        $pauseButton.Font = $linkLabelFont
        $pauseButton.ForeColor = [System.Drawing.Color]::Blue
        $pauseButton.Cursor = [System.Windows.Forms.Cursors]::Hand
        $pauseButton.TextAlign = 'MiddleCenter'
        
        $applyButton = New-Object System.Windows.Forms.Label
        $applyButton.Text = "Apply"
        $applyButton.Dock = 'Fill'
        $applyButton.Font = $linkLabelFont
        $applyButton.ForeColor = [System.Drawing.Color]::Blue
        $applyButton.Cursor = [System.Windows.Forms.Cursors]::Hand
        $applyButton.TextAlign = 'MiddleCenter'
        
        $mainTable.Controls.Add($plusButton, 0, 0)
        $mainTable.Controls.Add($pendingMinutesLabel, 1, 0)
        $mainTable.Controls.Add($minusButton, 2, 0)
        $mainTable.Controls.Add($label, 3, 0)
        $mainTable.Controls.Add($pauseButton, 4, 0)
        $mainTable.Controls.Add($applyButton, 5, 0)

        $toggleButtonsLabel = New-Object System.Windows.Forms.Label
        $toggleButtonsLabel.Text = "Show"
        $toggleButtonsLabel.Dock = 'Fill'
        $toggleButtonsLabel.TextAlign = 'MiddleCenter'
        $toggleButtonsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $toggleButtonsLabel.Cursor = [System.Windows.Forms.Cursors]::Hand

        # Apply initial hidden state
        $plusButton.Visible = $false
        $pendingMinutesLabel.Visible = $false
        $minusButton.Visible = $false
        $pauseButton.Visible = $false
        $applyButton.Visible = $false
        $mainTable.SetColumnSpan($label, 6) # Make the label span all 6 columns

        $formTable.Controls.Add($mainTable, 0, 0)
        $formTable.Controls.Add($toggleButtonsLabel, 0, 1)
        $form.Controls.Add($formTable)

        $plusButton.Add_Click({
            $script:pendingMinutes++
            $pendingMinutesLabel.Text = $script:pendingMinutes
        })
        $minusButton.Add_Click({
            $script:pendingMinutes--
            $pendingMinutesLabel.Text = $script:pendingMinutes
        })
        $applyButton.Add_Click({
            $secondsToAdd = $script:pendingMinutes * 60
            $newTotalSeconds = $script:totalSeconds + $secondsToAdd
            if ($newTotalSeconds -le 0) {
                [System.Windows.Forms.MessageBox]::Show("Resulting time must be greater than 00:00.", "Invalid Time", "OK", "Warning")
                return
            }
            $script:totalSeconds = $newTotalSeconds
            Update-LabelText -secondsLeft $script:totalSeconds
            $script:pendingMinutes = 0
            $pendingMinutesLabel.Text = "0"
        })
        $pauseButton.Add_Click({
            $script:isPaused = -not $script:isPaused
            if ($script:isPaused) {
                $timer.Stop()
                $pauseButton.Text = "Resume"
                $pauseButton.ForeColor = [System.Drawing.Color]::Red
            } else {
                $timer.Start()
                $pauseButton.Text = "Pause"
                $pauseButton.ForeColor = [System.Drawing.Color]::Blue
            }
        })
        
        $toggleButtonsLabel.Add_Click({
            $script:arePanelsHidden = -not $script:arePanelsHidden
            if ($script:arePanelsHidden) {
                # HIDE PANELS
                $script:largeWidth = $form.Width
                $plusButton.Visible = $false
                $pendingMinutesLabel.Visible = $false
                $minusButton.Visible = $false
                $pauseButton.Visible = $false
                $applyButton.Visible = $false
                $mainTable.SetColumnSpan($label, 6)
                $toggleButtonsLabel.Text = "Show"
                $form.MinimumSize = $smallMinSize
                $form.Size = New-Object System.Drawing.Size($smallWidth, $form.Height) 
            } else {
                # SHOW PANELS
                $form.MinimumSize = $largeMinSize
                $plusButton.Visible = $true
                $pendingMinutesLabel.Visible = $true
                $minusButton.Visible = $true
                $pauseButton.Visible = $true
                $applyButton.Visible = $true
                $mainTable.SetColumnSpan($label, 1)
                $toggleButtonsLabel.Text = "Hide"
                if ($script:largeWidth -lt $largeMinSize.Width) { $script:largeWidth = $largeMinSize.Width }
                $form.Size = New-Object System.Drawing.Size($script:largeWidth, $form.Height)
            }
        })

        # --- HELPER FUNCTIONS FOR RESIZING AND UPDATING ---
        
        function Update-FontScaling {
            if ($form.WindowState -ne 'Minimized') {
                try {
                    $newFontSize = [math]::Floor($label.Height / 2.5)
                    if ($newFontSize -lt 8) { $newFontSize = 8 }
                    
                    if ($label.Font.Size -ne $newFontSize) {
                        $fontGarbageCollector.Add($label.Font)
                        $label.Font = New-Object System.Drawing.Font("Segoe UI", $newFontSize, [System.Drawing.FontStyle]::Bold)
                    }
                }
                catch { }
            }
        }

        function Update-LabelText {
            param($secondsLeft)
            $minutes = [math]::Floor($secondsLeft / 60)
            $seconds = $secondsLeft % 60
            $label.Text = "{0:00}:{1:00}" -f $minutes, $seconds
        }
        
        # --- END HELPER FUNCTIONS ---

        $form.Add_ResizeEnd({
            Update-FontScaling
        })
        
        Update-LabelText -secondsLeft $totalSeconds

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 1000
        $timer.Add_Tick({
            $script:totalSeconds--
            if ($script:totalSeconds -lt 0) {
                $timer.Stop()
                if ($playSound -eq 'Y') {
                    try {
                        if (Test-Path $soundFile) {
                            $soundPlayer = New-Object System.Media.SoundPlayer($soundFile)
                            $soundPlayer.PlaySync()
                        } else { 
                            [System.Media.SystemSounds]::Beep.Play() 
                        }
                    } catch { 
                        [System.Media.SystemSounds]::Beep.Play() 
                    }
                }
                $form.Close()
            } else {
                Update-LabelText -secondsLeft $script:totalSeconds
            }
        })

        $form.Add_Shown({ 
            $timer.Start() 
            Update-FontScaling
        })

        # Clean up all fonts on closing
        $form.Add_FormClosing({
            foreach ($oldFont in $fontGarbageCollector) {
                $oldFont.Dispose()
            }
            $fontGarbageCollector.Clear()

            if ($label.Font) { $label.Font.Dispose() }
            if ($pendingMinutesLabel.Font) { $pendingMinutesLabel.Font.Dispose() }
            if ($toggleButtonsLabel.Font) { $toggleButtonsLabel.Font.Dispose() }
            if ($sideLabelFont) { $sideLabelFont.Dispose() }
            if ($linkLabelFont) { $linkLabelFont.Dispose() }
        })

        if (-not ("Win32.WindowManager" -as [type])) {
            Add-Type -TypeDefinition @"
            using System; using System.Runtime.InteropServices;
            namespace Win32 { public class WindowManager {
            [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            }}
"@
        }
        $consoleWindowHandle = (Get-Process -Id $PID).MainWindowHandle
        if ($consoleWindowHandle -ne [System.IntPtr]::Zero) {
            [Win32.WindowManager]::ShowWindow($consoleWindowHandle, 6)
        }
        
        $form.ShowDialog() | Out-Null
        
        $form.Dispose()
        $timer.Dispose()
    } else {
        break
    }
} # End of main while loop

# Script finishes here.
