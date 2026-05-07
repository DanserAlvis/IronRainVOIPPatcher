# ============================================================
# PROTOCOLO DE ELEVACIÓN HÍBRIDO (V2.5) - COMPATIBLE CON .EXE
# ============================================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $isExe = $false
    $scriptPath = $PSCommandPath
    
    if ([string]::IsNullOrWhiteSpace($scriptPath)) { $scriptPath = $MyInvocation.MyCommand.Path }
    
    # Si las variables de script fallan, significa que estamos dentro de un .EXE compilado
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        $scriptPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        $isExe = $true
    }

    try {
        if ($isExe -or $scriptPath.EndsWith(".exe", [System.StringComparison]::OrdinalIgnoreCase)) {
            # Relanzar el propio EXE como Administrador
            Start-Process -FilePath "$scriptPath" -Verb RunAs
        } else {
            # Relanzar el PS1 a traves de PowerShell como Administrador
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Normal -File `"$scriptPath`""
        }
        exit
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Windows (UAC) bloqueo la auto-elevacion de permisos. Por favor, haz clic derecho en el programa y selecciona 'Ejecutar como Administrador'.", "ERROR DE PERMISOS", "OK", "Error")
        exit
    }
}

# ============================================================
# INTERFAZ GRAFICA Y LOGICA
# ============================================================
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "EDF: Iron Rain - VOIP Master Patcher V2.5"
    $form.Size = New-Object System.Drawing.Size(800, 700)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 20)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $fontNormal = New-Object System.Drawing.Font("Segoe UI", 9)
    $fontBold = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

    $labelTitle = New-Object System.Windows.Forms.Label
    $labelTitle.Text = "GESTOR DEFINITIVO DE VOIP (HOST FIX)"
    $labelTitle.ForeColor = [System.Drawing.Color]::Cyan
    $labelTitle.Location = New-Object System.Drawing.Point(20, 15)
    $labelTitle.AutoSize = $true
    $labelTitle.Font = $fontTitle
    $form.Controls.Add($labelTitle)

    # --- INSTRUCCIONES DE BÚSQUEDA ---
    $lblHelp = New-Object System.Windows.Forms.Label
    $lblHelp.Text = "[*] ARCHIVO REQUERIDO: Engine.ini`nUbicacion tipica: C:\Users\[TuUsuario]\AppData\Local\EDFIR\Saved\Config\WindowsNoEditor"
    $lblHelp.Location = New-Object System.Drawing.Point(20, 50)
    $lblHelp.Size = New-Object System.Drawing.Size(760, 40)
    $lblHelp.ForeColor = [System.Drawing.Color]::LightSkyBlue
    $lblHelp.Font = $fontBold
    $form.Controls.Add($lblHelp)

    # --- SISTEMA DE RUTA DINÁMICA ---
    $script:engineIni = "$env:LOCALAPPDATA\EDFIR\Saved\Config\WindowsNoEditor\Engine.ini"

    $labelPath = New-Object System.Windows.Forms.Label
    $labelPath.Location = New-Object System.Drawing.Point(20, 105)
    $labelPath.Size = New-Object System.Drawing.Size(650, 30)
    $labelPath.Font = New-Object System.Drawing.Font("Consolas", 8)

    if (Test-Path $script:engineIni) {
        $labelPath.Text = "RUTA: $script:engineIni"
        $labelPath.ForeColor = [System.Drawing.Color]::Gray
    } else {
        $labelPath.Text = "ARCHIVO NO ENCONTRADO. USA EL BOTON ->"
        $labelPath.ForeColor = [System.Drawing.Color]::Red
    }
    $form.Controls.Add($labelPath)

    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Text = "BUSCAR"
    $btnBrowse.Location = New-Object System.Drawing.Point(680, 100)
    $btnBrowse.Size = New-Object System.Drawing.Size(100, 25)
    $btnBrowse.BackColor = [System.Drawing.Color]::DarkSlateGray
    $btnBrowse.ForeColor = [System.Drawing.Color]::White
    $btnBrowse.FlatStyle = "Flat"
    $btnBrowse.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($btnBrowse)

    # --- PANEL DE OPCIONES ---
    $groupOptions = New-Object System.Windows.Forms.GroupBox
    $groupOptions.Text = "Selecciona el tipo de Parche a Inyectar"
    $groupOptions.ForeColor = [System.Drawing.Color]::Gold
    $groupOptions.Location = New-Object System.Drawing.Point(20, 160)
    $groupOptions.Size = New-Object System.Drawing.Size(760, 140)
    $groupOptions.Font = $fontNormal
    $form.Controls.Add($groupOptions)

    $radKiller = New-Object System.Windows.Forms.RadioButton
    $radKiller.Text = "1. VOIP KILLER: Amputa el chat. Cero tirones garantizado."
    $radKiller.Location = New-Object System.Drawing.Point(15, 30)
    $radKiller.Width = 730
    $radKiller.Checked = $true
    $radKiller.ForeColor = [System.Drawing.Color]::White
    $groupOptions.Controls.Add($radKiller)

    $radRescue1 = New-Object System.Windows.Forms.RadioButton
    $radRescue1.Text = "2. VOIP RESCUE V1: Mic activo. Intenta mover el audio a segundo plano."
    $radRescue1.Location = New-Object System.Drawing.Point(15, 65)
    $radRescue1.Width = 730
    $radRescue1.ForeColor = [System.Drawing.Color]::White
    $groupOptions.Controls.Add($radRescue1)

    $radRescue2 = New-Object System.Windows.Forms.RadioButton
    $radRescue2.Text = "3. VOIP RESCUE V2: Mic activo. Baja calidad (8000Hz) y sin Eco."
    $radRescue2.Location = New-Object System.Drawing.Point(15, 100)
    $radRescue2.Width = 730
    $radRescue2.ForeColor = [System.Drawing.Color]::White
    $groupOptions.Controls.Add($radRescue2)

    # --- LOG ---
    $txtLog = New-Object System.Windows.Forms.TextBox
    $txtLog.Location = New-Object System.Drawing.Point(20, 320)
    $txtLog.Size = New-Object System.Drawing.Size(760, 180)
    $txtLog.Multiline = $true
    $txtLog.ScrollBars = "Vertical"
    $txtLog.ReadOnly = $true
    $txtLog.BackColor = [System.Drawing.Color]::Black
    $txtLog.ForeColor = [System.Drawing.Color]::Lime
    $txtLog.Font = New-Object System.Drawing.Font("Consolas", 8)
    $txtLog.Text = "[SISTEMA]: Gestor iniciado con permisos de Administrador.\r\n"
    $form.Controls.Add($txtLog)

    # --- BOTONES ---
    $btnApply = New-Object System.Windows.Forms.Button
    $btnApply.Text = "APLICAR PARCHE SELECCIONADO"
    $btnApply.Location = New-Object System.Drawing.Point(20, 515)
    $btnApply.Size = New-Object System.Drawing.Size(760, 40)
    $btnApply.BackColor = [System.Drawing.Color]::DarkRed
    $btnApply.ForeColor = [System.Drawing.Color]::White
    $btnApply.FlatStyle = "Flat"
    $btnApply.Font = $fontTitle
    $form.Controls.Add($btnApply)

    $btnRestore = New-Object System.Windows.Forms.Button
    $btnRestore.Text = "ELIMINAR PARCHES DE VOIP (Restaurar)"
    $btnRestore.Location = New-Object System.Drawing.Point(20, 570)
    $btnRestore.Size = New-Object System.Drawing.Size(760, 35)
    $btnRestore.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 45)
    $btnRestore.ForeColor = [System.Drawing.Color]::White
    $btnRestore.FlatStyle = "Flat"
    $form.Controls.Add($btnRestore)

    # --- LÓGICA DE EVENTOS ---

    $btnBrowse.Add_Click({
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Filter = "Archivos INI (*.ini)|*.ini|Todos los archivos (*.*)|*.*"
        $fileDialog.Title = "Selecciona el archivo Engine.ini"
        
        $defaultDir = "$env:LOCALAPPDATA\EDFIR\Saved\Config\WindowsNoEditor"
        if (Test-Path $defaultDir) { $fileDialog.InitialDirectory = $defaultDir }

        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $script:engineIni = $fileDialog.FileName
            $labelPath.Text = "RUTA MANUAL: $script:engineIni"
            $labelPath.ForeColor = [System.Drawing.Color]::Lime
            $txtLog.AppendText("[SISTEMA]: Ruta actualizada manualmente.\r\n")
        }
    })

    $btnApply.Add_Click({
        try {
            if (-not (Test-Path $script:engineIni)) {
                $txtLog.AppendText("[ERROR]: No se encontro el archivo en la ruta especificada. Usa el boton BUSCAR.\r\n")
                return
            }

            Set-ItemProperty -Path $script:engineIni -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
            $content = Get-Content $script:engineIni -Raw
            
            $content = $content -replace '(?s);=== VOIP KILLER START ===.*;=== VOIP KILLER END ===\s*', ''
            $content = $content -replace '(?s);=== VOIP RESCUE START ===.*;=== VOIP RESCUE END ===\s*', ''
            $content = $content -replace '(?s);=== VOIP RESCUE V2 START ===.*;=== VOIP RESCUE V2 END ===\s*', ''
            $content = $content -replace '(?s);=== VOIP PATCH START ===.*;=== VOIP PATCH END ===\s*', ''
            $content = $content.Trim()

            $injection = "`r`n`r`n;=== VOIP PATCH START ===`r`n"

            if ($radKiller.Checked) {
                $injection += "[Voice]`r`nbEnabled=False`r`n`r`n[OnlineSubsystem]`r`nbHasVoiceEnabled=False`r`n`r`n[OnlineSubsystemSteam]`r`nbHasVoiceEnabled=False`r`n`r`n[/Script/Engine.GameSession]`r`nbRequiresPushToTalk=True`r`n"
                $txtLog.AppendText("[MODO]: VOIP KILLER (Chat Amputado).\r\n")
            }
            elseif ($radRescue1.Checked) {
                $injection += "[Voice]`r`nbEnabled=True`r`nSilenceDetectionThreshold=0.05`r`n`r`n[Core.Log]`r`nLogVoice=Error`r`nLogOnline=Error`r`n`r`n[SystemSettings]`r`nAudioThread.UseBackgroundThreadPool=1`r`nAudioThread.EnableBatchProcessing=1`r`nAudioThread.AboveNormalPriority=1`r`n`r`n[/Script/Engine.GameSession]`r`nbRequiresPushToTalk=True`r`n"
                $txtLog.AppendText("[MODO]: VOIP RESCUE V1 (Hilos de Fondo).\r\n")
            }
            elseif ($radRescue2.Checked) {
                $injection += "[Voice]`r`nbEnabled=True`r`nbDisableEchoCancellation=True`r`nVoiceSampleRate=8000`r`nSilenceDetectionThreshold=0.15`r`n`r`n[SystemSettings]`r`nvoice.bDisableEchoCancellation=1`r`nvoice.PlaybackQuality=0`r`nnet.VoiceDataMaxInMegabytes=1`r`n`r`n[/Script/Engine.GameSession]`r`nbRequiresPushToTalk=True`r`n"
                $txtLog.AppendText("[MODO]: VOIP RESCUE V2 (Audio Baja Calidad).\r\n")
            }

            $injection += ";=== VOIP PATCH END ===`r`n"

            Set-Content -Path $script:engineIni -Value ($content + $injection) -Encoding ASCII
            Set-ItemProperty -Path $script:engineIni -Name IsReadOnly -Value $true

            $txtLog.AppendText("[EXITO]: Parche inyectado y archivo blindado.\r\n")
        } catch {
            $txtLog.AppendText("[ERROR]: " + $_.Exception.Message + "\r\n")
        }
    })

    $btnRestore.Add_Click({
        try {
            if (-not (Test-Path $script:engineIni)) { 
                $txtLog.AppendText("[ERROR]: Ruta no valida. Usa BUSCAR.\r\n")
                return 
            }

            Set-ItemProperty -Path $script:engineIni -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
            
            $content = Get-Content $script:engineIni -Raw
            $content = $content -replace '(?s);=== VOIP KILLER START ===.*;=== VOIP KILLER END ===\s*', ''
            $content = $content -replace '(?s);=== VOIP RESCUE START ===.*;=== VOIP RESCUE END ===\s*', ''
            $content = $content -replace '(?s);=== VOIP RESCUE V2 START ===.*;=== VOIP RESCUE V2 END ===\s*', ''
            $content = $content -replace '(?s);=== VOIP PATCH START ===.*;=== VOIP PATCH END ===\s*', ''
            $content = $content.Trim()

            Set-Content -Path $script:engineIni -Value $content -Encoding ASCII
            $txtLog.AppendText("[RESTAURACION]: Se han eliminado todos los parches de VOIP. Archivo desblindado.\r\n")
        } catch {
            $txtLog.AppendText("[ERROR]: " + $_.Exception.Message + "\r\n")
        }
    })

    [void]$form.ShowDialog()

} catch {
    [System.Windows.Forms.MessageBox]::Show("Error critico en la interfaz grafica: " + $_.Exception.Message, "ERROR FATAL", "OK", "Error")
}