<#
.SYNOPSIS
A reusable countdown timer with a GUI that stays on top of all other windows.

.DESCRIPTION
This script launches an input form to set a countdown. After the countdown finishes,
the script returns to the input form. When the "Exit" button is pressed, a final
credits window is displayed before the application closes.

.NOTES
To use:
1. Save this code as a PowerShell script file (e.g., countdown_timer.ps1).
2. (Optional) Create a 'config.txt' file in the same directory to customize the countdown window's appearance.
3. Run the script: .\countdown_timer.ps1
4. Use the input form to set the time and click "Start", or click "Exit" to close.
#>

#-----------------------------------------------------------------------
# CONFIGURATION - Change these values to customize the timer
#-----------------------------------------------------------------------

# Set the path to the sound file to play when the timer ends.
$soundFile = "C:\Windows\Media\Alarm02.wav"

# Set the path to the icon file (.ico) for the window.
$iconFile = ".\favicon.ico" # Example path, change as needed

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
    $inputForm.Size = New-Object System.Drawing.Size(300, 200) # Resized for 3 buttons
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

    # --- MODIFIED EXIT BUTTON HANDLER ---
    $exitButton.Add_Click({
        # First, show the credits window
        $creditsForm = New-Object System.Windows.Forms.Form
        $creditsForm.Text = "Credits"
        $creditsForm.Size = New-Object System.Drawing.Size(400, 200)
        $creditsForm.StartPosition = 'CenterParent'
        $creditsForm.FormBorderStyle = 'FixedDialog'
        $creditsForm.MaximizeBox = $false
        $creditsForm.MinimizeBox = $false

        $autoCloseTimer = New-Object System.Windows.Forms.Timer
        $autoCloseTimer.Interval = 15000 # 15 seconds
        $autoCloseTimer.Add_Tick({
            if ($creditsForm.Visible) { $creditsForm.Close() }
        })

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
        
        # Clean up credits resources
        $creditsForm.Dispose()
        $autoCloseTimer.Dispose()

        # After the credits window is closed, set the flag to terminate the script
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

        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Countdown"
        $form.Size = New-Object System.Drawing.Size($settings.WindowWidth, $settings.WindowHeight)
        $form.StartPosition = 'CenterScreen'
        $form.FormBorderStyle = 'FixedSingle'
        $form.MaximizeBox = $false
        $form.MinimizeBox = $true
        $form.Topmost = $true

        if (Test-Path $iconFile) {
            try { $form.Icon = [System.Drawing.Icon]::new($iconFile) }
            catch { Write-Warning "Failed to load icon: $iconFile." }
        }

        $label = New-Object System.Windows.Forms.Label
        $label.Font = New-Object System.Drawing.Font("Segoe UI", $settings.FontSize, [System.Drawing.FontStyle]::Bold)
        $label.Dock = 'Fill'
        $label.TextAlign = 'MiddleCenter'
        $form.Controls.Add($label)

        function Update-LabelText {
            param($secondsLeft)
            $minutes = [math]::Floor($secondsLeft / 60)
            $seconds = $secondsLeft % 60
            $label.Text = "{0:00}:{1:00}" -f $minutes, $seconds
        }

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
                        } else { [System.Media.SystemSounds]::Beep.Play() }
                    } catch { [System.Media.SystemSounds]::Beep.Play() }
                }
                $form.Close()
            } else {
                Update-LabelText -secondsLeft $script:totalSeconds
            }
        })

        $form.Add_Shown({ $timer.Start() })

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