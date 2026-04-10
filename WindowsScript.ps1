# ============================================================
# SCRIPT DE GERENCIAMENTO DE USUARIOS - WINDOWS
# Autor: Bernardo
# Versao: 7.0 - Com Monitoramento de Processos
# ============================================================

# ========== CONFIGURACOES ==========
$VERDE = "Green"
$VERMELHO = "Red"
$AMARELO = "Yellow"
$AZUL = "Cyan"
$ROXO = "Magenta"
$CIANO = "Cyan"

# Arquivo para armazenar usuarios (simulacao local)
$USERS_FILE = "$env:USERPROFILE\.script_usuarios.txt"
$LOG_FILE = "$env:USERPROFILE\.script_windows_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# ========== INICIALIZAR ARQUIVO DE USUARIOS ==========
function Inicializar-Arquivo {
    if (-not (Test-Path $USERS_FILE)) {
        $conteudo = @"
joao:Joao Silva:/bin/bash:ativo
maria:Maria Santos:/bin/bash:ativo
carlos:Carlos Alberto:/bin/bash:ativo
ana:Ana Paula:/bin/bash:ativo
pedro:Pedro Lima:/bin/bash:ativo
"@
        Set-Content -Path $USERS_FILE -Value $conteudo -Encoding UTF8
        Write-Host "Arquivo de usuarios criado: $USERS_FILE"
    }
}

# ========== FUNCAO PARA LOG ==========
function Write-Log {
    param($tipo, $msg)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [$tipo] - $msg" | Out-File -FilePath $LOG_FILE -Append
}

# ========== FUNCAO PARA MOSTRAR MENSAGENS ==========
function Write-Mensagem {
    param($tipo, $texto)
    
    switch ($tipo) {
        "ERRO" { Write-Host "ERRO: $texto" -ForegroundColor Red }
        "SUCESSO" { Write-Host "SUCESSO: $texto" -ForegroundColor Green }
        "AVISO" { Write-Host "AVISO: $texto" -ForegroundColor Yellow }
        "INFO" { Write-Host "INFO: $texto" -ForegroundColor Cyan }
        "TITULO" { Write-Host "$texto" -ForegroundColor Cyan }
    }
    Write-Log -tipo $tipo -msg $texto
}

# ========== FUNCAO PARA MONITORAR PROCESSOS ==========
function Monitorar-Processos {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                 MONITORAMENTO DE PROCESSOS                " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "O que voce quer monitorar?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   1. Monitorar um processo especifico (por nome)"
    Write-Host "   2. Ver todos os processos do sistema"
    Write-Host "   3. Ver processos de um usuario especifico"
    Write-Host "   4. Ver processos mais pesados (CPU/Memoria)"
    Write-Host "   5. Monitorar processo em tempo real (top)"
    Write-Host "   6. Monitorar processo por tempo (ex: 10 segundos)"
    Write-Host "   7. Ver processos de um usuario do script"
    Write-Host "   8. Voltar"
    Write-Host ""
    
    $opcao_proc = Read-Host "Escolha (1-8)"
    
    switch ($opcao_proc) {
        "1" {
            $processo = Read-Host "Digite o nome do processo (ex: powershell, chrome, notepad)"
            Write-Host ""
            Write-Host "Processos encontrados para '$processo':" -ForegroundColor Cyan
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Get-Process -Name "*$processo*" -ErrorAction SilentlyContinue | Format-Table -AutoSize
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
        }
        "2" {
            Write-Host ""
            Write-Host "TODOS OS PROCESSOS DO SISTEMA:" -ForegroundColor Cyan
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Get-Process | Select-Object -First 20 | Format-Table -AutoSize
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Write-Host "Total de processos: $( (Get-Process).Count )" -ForegroundColor Cyan
        }
        "3" {
            $usuario_proc = Read-Host "Digite o nome do usuario"
            Write-Host ""
            Write-Host "Processos do usuario '$usuario_proc':" -ForegroundColor Cyan
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*$usuario_proc*" } | Format-Table -AutoSize
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
        }
        "4" {
            Write-Host ""
            Write-Host "TOP 10 PROCESSOS MAIS PESADOS (CPU):" -ForegroundColor Cyan
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table -AutoSize
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "TOP 10 PROCESSOS MAIS PESADOS (MEMORIA):" -ForegroundColor Cyan
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | Format-Table -AutoSize
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
        }
        "5" {
            Write-Host ""
            Write-Host "Abrindo monitor em tempo real..." -ForegroundColor Cyan
            Write-Host "Pressione 'Ctrl+C' para sair do monitor" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            while ($true) {
                Clear-Host
                Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize
                Start-Sleep -Seconds 2
            }
        }
        "6" {
            $processo_mon = Read-Host "Digite o nome do processo para monitorar"
            $tempo_mon = Read-Host "Digite o tempo de monitoramento (segundos)"
            Write-Host ""
            
            if (-not ($tempo_mon -match '^\d+$')) {
                Write-Mensagem -tipo "ERRO" -texto "Tempo invalido! Usando 10 segundos"
                $tempo_mon = 10
            }
            
            Write-Host "Monitorando '$processo_mon' por $tempo_mon segundos..." -ForegroundColor Cyan
            Write-Host ""
            
            $encontrado = $false
            for ($i = 1; $i -le $tempo_mon; $i++) {
                if (Get-Process -Name "*$processo_mon*" -ErrorAction SilentlyContinue) {
                    Write-Host "[$i/$tempo_mon] Processo '$processo_mon' esta em execucao!" -ForegroundColor Green
                    $encontrado = $true
                } else {
                    Write-Host "[$i/$tempo_mon] Aguardando processo '$processo_mon'..." -ForegroundColor Yellow
                }
                Start-Sleep -Seconds 1
            }
            
            if ($encontrado) {
                Write-Mensagem -tipo "SUCESSO" -texto "Processo monitorado com sucesso"
            } else {
                Write-Mensagem -tipo "AVISO" -texto "Processo nao encontrado durante o monitoramento"
            }
        }
        "7" {
            Write-Host ""
            Write-Host "Usuarios cadastrados no script:" -ForegroundColor Cyan
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            
            $usuarios = Get-Content $USERS_FILE
            $i = 1
            foreach ($linha in $usuarios) {
                $user = ($linha -split ':')[0]
                Write-Host "$i. $user"
                $i++
            }
            Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
            Write-Host ""
            
            $num_user = Read-Host "Digite o numero do usuario para ver seus processos"
            
            if ($num_user -match '^\d+$') {
                $usuario_sistema = ($usuarios[$num_user - 1] -split ':')[0]
                if ($usuario_sistema) {
                    Write-Host ""
                    Write-Host "Processos do usuario '$usuario_sistema' (no sistema real):" -ForegroundColor Cyan
                    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
                    Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*$usuario_sistema*" } | Format-Table -AutoSize
                    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
                }
            }
        }
        "8" { return }
        default { Write-Mensagem -tipo "ERRO" -texto "Opcao invalida!" }
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNCAO PARA LISTAR TODOS OS USUARIOS ==========
function Listar-Usuarios {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                      LISTA DE USUARIOS                    " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ((Get-Content $USERS_FILE).Count -eq 0) {
        Write-Mensagem -tipo "AVISO" -texto "Nenhum usuario cadastrado!"
        Write-Host ""
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $total = (Get-Content $USERS_FILE).Count
    Write-Host "Total de usuarios: $total" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "N   USUARIO          NOME COMPLETO               SHELL        STATUS" -ForegroundColor Green
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    
    $num = 1
    foreach ($linha in Get-Content $USERS_FILE) {
        $campos = $linha -split ':'
        $user = $campos[0]
        $name = $campos[1]
        $shell = $campos[2]
        $status = $campos[3]
        
        if ($status -eq "ativo") {
            $status_show = "ATIVO"
            $cor = "Green"
        } else {
            $status_show = "BLOQUEADO"
            $cor = "Red"
        }
        
        Write-Host ("{0,-3} {1,-15} {2,-25} {3,-12} " -f $num, $user, $name, $shell) -NoNewline
        Write-Host $status_show -ForegroundColor $cor
        $num++
    }
    
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    $escolha = Read-Host "Digite o numero do usuario para ver detalhes (0 para voltar)"
    
    if ($escolha -gt 0) {
        Ver-DetalhesUsuario -num $escolha
    }
}

# ========== FUNCAO PARA VER DETALHES DE UM USUARIO ==========
function Ver-DetalhesUsuario {
    param($num)
    
    $linha = (Get-Content $USERS_FILE)[$num - 1]
    
    if (-not $linha) {
        Write-Mensagem -tipo "ERRO" -texto "Usuario nao encontrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $campos = $linha -split ':'
    $user = $campos[0]
    $name = $campos[1]
    $shell = $campos[2]
    $status = $campos[3]
    
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                   DETALHES DO USUARIO                     " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Informacoes:" -ForegroundColor Cyan
    Write-Host "   Usuario: $user"
    Write-Host "   Nome completo: $name"
    Write-Host "   Shell: $shell"
    Write-Host "   Status: $(if ($status -eq 'ativo') { 'ATIVO' } else { 'BLOQUEADO' })"
    Write-Host ""
    Write-Host "Diretorio home simulado: C:\Users\$user" -ForegroundColor Cyan
    Write-Host "UID simulado: $((1000 + $num))" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNCAO PARA PERGUNTAR SIM/NAO ==========
function Confirmar-Acao {
    param($pergunta)
    
    while ($true) {
        $resposta = Read-Host "$pergunta (s/n)"
        switch ($resposta.ToLower()) {
            "s" { return $true }
            "n" { return $false }
            default { Write-Host "Responda 's' ou 'n'" -ForegroundColor Red }
        }
    }
}

# ========== FUNCAO PARA CRIAR USUARIO ==========
function Criar-Usuario {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                     CRIAR USUARIO                        " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "REGRAS:" -ForegroundColor Cyan
    Write-Host "   - Login: letras minusculas (a-z), numeros, _ e -"
    Write-Host "   - Login deve comecar com letra"
    Write-Host "   - Exemplos: joao, maria_silva, user123"
    Write-Host ""
    
    while ($true) {
        $login = Read-Host "Login do usuario"
        $login = $login.ToLower()
        
        if ($login -notmatch '^[a-z][a-z0-9_-]*$') {
            Write-Mensagem -tipo "ERRO" -texto "Login invalido! Use apenas letras minusculas, numeros, _ e -"
            continue
        }
        
        if ((Get-Content $USERS_FILE) -match "^$login") {
            Write-Mensagem -tipo "ERRO" -texto "Usuario '$login' ja existe!"
            continue
        }
        break
    }
    
    $nome_completo = Read-Host "Nome completo"
    if (-not $nome_completo) { $nome_completo = $login }
    
    Write-Host ""
    Write-Host "Shell disponiveis:" -ForegroundColor Cyan
    Write-Host "   1. powershell.exe"
    Write-Host "   2. cmd.exe"
    Write-Host "   3. bash.exe (WSL)"
    $shell_opcao = Read-Host "Escolha o shell (1-3) [padrao=1]"
    
    switch ($shell_opcao) {
        "2" { $shell = "cmd.exe" }
        "3" { $shell = "bash.exe" }
        default { $shell = "powershell.exe" }
    }
    
    Write-Host ""
    while ($true) {
        $senha = Read-Host "Senha" -AsSecureString
        $senha2 = Read-Host "Confirmar senha" -AsSecureString
        
        $senha_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))
        $senha2_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha2))
        
        if ($senha_texto -ne $senha2_texto) {
            Write-Mensagem -tipo "ERRO" -texto "Senhas nao conferem!"
        } elseif ($senha_texto.Length -lt 4) {
            Write-Mensagem -tipo "ERRO" -texto "Senha muito curta (minimo 4 caracteres)"
        } else {
            break
        }
    }
    
    Write-Host ""
    Write-Host "Resumo:" -ForegroundColor Cyan
    Write-Host "   Login: $login"
    Write-Host "   Nome: $nome_completo"
    Write-Host "   Shell: $shell"
    Write-Host ""
    
    if (Confirmar-Acao "Confirmar criacao do usuario?") {
        "$login`:$nome_completo`:$shell`:ativo" | Out-File -FilePath $USERS_FILE -Append -Encoding UTF8
        Write-Mensagem -tipo "SUCESSO" -texto "Usuario '$login' criado com sucesso!"
        
        "$login`:$senha_texto" | Out-File -FilePath "$env:USERPROFILE\.script_senhas.txt" -Append -Encoding UTF8
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNCAO PARA EDITAR USUARIO ==========
function Editar-Usuario {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                     EDITAR USUARIO                       " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ((Get-Content $USERS_FILE).Count -eq 0) {
        Write-Mensagem -tipo "AVISO" -texto "Nenhum usuario cadastrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    Write-Host "USUARIOS CADASTRADOS:" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "N   LOGIN            NOME" -ForegroundColor Green
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    
    $usuarios = Get-Content $USERS_FILE
    $num = 1
    foreach ($linha in $usuarios) {
        $campos = $linha -split ':'
        $user = $campos[0]
        $name = $campos[1]
        Write-Host ("{0,-3} {1,-15} {2,-25}" -f $num, $user, $name)
        $num++
    }
    
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    $escolha = Read-Host "Digite o numero do usuario para editar (0 para voltar)"
    
    if ($escolha -eq 0) { return }
    
    if ($escolha -notmatch '^\d+$') {
        Write-Mensagem -tipo "ERRO" -texto "Numero invalido!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $linha = $usuarios[$escolha - 1]
    if (-not $linha) {
        Write-Mensagem -tipo "ERRO" -texto "Usuario nao encontrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $campos = $linha -split ':'
    $old_user = $campos[0]
    $old_name = $campos[1]
    $old_shell = $campos[2]
    $old_status = $campos[3]
    
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "              EDITANDO USUARIO: $old_user                 " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "O que deseja editar?" -ForegroundColor Cyan
    Write-Host "   1. Nome completo"
    Write-Host "   2. Shell"
    Write-Host "   3. Status (Ativo/Bloqueado)"
    Write-Host "   4. Senha"
    Write-Host "   5. Voltar"
    Write-Host ""
    
    $opcao = Read-Host "Escolha (1-5)"
    
    switch ($opcao) {
        "1" {
            $novo_nome = Read-Host "Novo nome completo [atual: $old_name]"
            if ($novo_nome) { $old_name = $novo_nome }
        }
        "2" {
            Write-Host "Shells: 1-powershell.exe 2-cmd.exe 3-bash.exe (WSL)"
            $shell_opcao = Read-Host "Novo shell [atual: $old_shell]"
            switch ($shell_opcao) {
                "2" { $old_shell = "cmd.exe" }
                "3" { $old_shell = "bash.exe" }
                default { $old_shell = "powershell.exe" }
            }
        }
        "3" {
            if ($old_status -eq "ativo") {
                $old_status = "bloqueado"
                Write-Mensagem -tipo "INFO" -texto "Usuario sera BLOQUEADO"
            } else {
                $old_status = "ativo"
                Write-Mensagem -tipo "INFO" -texto "Usuario sera ATIVADO"
            }
        }
        "4" {
            while ($true) {
                $nova_senha = Read-Host "Nova senha" -AsSecureString
                $confirma_senha = Read-Host "Confirmar senha" -AsSecureString
                
                $nova_senha_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($nova_senha))
                $confirma_senha_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirma_senha))
                
                if ($nova_senha_texto -ne $confirma_senha_texto) {
                    Write-Mensagem -tipo "ERRO" -texto "Senhas nao conferem!"
                } elseif ($nova_senha_texto.Length -lt 4) {
                    Write-Mensagem -tipo "ERRO" -texto "Senha muito curta!"
                } else {
                    $senhas_file = "$env:USERPROFILE\.script_senhas.txt"
                    if (Test-Path $senhas_file) {
                        $conteudo = Get-Content $senhas_file | Where-Object { $_ -notmatch "^$old_user" }
                        $conteudo | Set-Content $senhas_file -Encoding UTF8
                    }
                    "$old_user`:$nova_senha_texto" | Out-File -FilePath $senhas_file -Append -Encoding UTF8
                    Write-Mensagem -tipo "SUCESSO" -texto "Senha alterada!"
                    break
                }
            }
        }
        "5" { return }
        default { Write-Mensagem -tipo "ERRO" -texto "Opcao invalida!" }
    }
    
    if ($opcao -ge 1 -and $opcao -le 3) {
        $novaLinha = "$old_user`:$old_name`:$old_shell`:$old_status"
        $conteudo = Get-Content $USERS_FILE
        $conteudo[$escolha - 1] = $novaLinha
        $conteudo | Set-Content $USERS_FILE -Encoding UTF8
        Write-Mensagem -tipo "SUCESSO" -texto "Usuario atualizado com sucesso!"
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNCAO PARA DELETAR USUARIO ==========
function Deletar-Usuario {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                    DELETAR USUARIO                     " -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ((Get-Content $USERS_FILE).Count -eq 0) {
        Write-Mensagem -tipo "AVISO" -texto "Nenhum usuario cadastrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    Write-Host "USUARIOS CADASTRADOS:" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "N   LOGIN            NOME                         STATUS" -ForegroundColor Green
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    
    $usuarios = Get-Content $USERS_FILE
    $num = 1
    foreach ($linha in $usuarios) {
        $campos = $linha -split ':'
        $user = $campos[0]
        $name = $campos[1]
        $status = $campos[3]
        Write-Host ("{0,-3} {1,-15} {2,-25} [{3}]" -f $num, $user, $name, $status)
        $num++
    }
    
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    $escolha = Read-Host "Digite o numero do usuario para DELETAR (0 para voltar)"
    
    if ($escolha -eq 0) { return }
    
    if ($escolha -notmatch '^\d+$') {
        Write-Mensagem -tipo "ERRO" -texto "Numero invalido!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $linha = $usuarios[$escolha - 1]
    if (-not $linha) {
        Write-Mensagem -tipo "ERRO" -texto "Usuario nao encontrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $campos = $linha -split ':'
    $user = $campos[0]
    $name = $campos[1]
    $status = $campos[3]
    
    Write-Host ""
    Write-Host "ATENCAO: Voce esta prestes a DELETAR o usuario '$user'" -ForegroundColor Red
    Write-Host "   Nome: $name" -ForegroundColor Cyan
    Write-Host "   Status: $status" -ForegroundColor Cyan
    Write-Host ""
    
    if (Confirmar-Acao "Tem certeza que deseja DELETAR este usuario?") {
        $conteudo = Get-Content $USERS_FILE
        $conteudo = $conteudo[0..($escolha-2)] + $conteudo[$escolha..($conteudo.Length-1)]
        $conteudo | Set-Content $USERS_FILE -Encoding UTF8
        
        $senhas_file = "$env:USERPROFILE\.script_senhas.txt"
        if (Test-Path $senhas_file) {
            $conteudo_senhas = Get-Content $senhas_file | Where-Object { $_ -notmatch "^$user" }
            $conteudo_senhas | Set-Content $senhas_file -Encoding UTF8
        }
        
        Write-Mensagem -tipo "SUCESSO" -texto "Usuario '$user' foi DELETADO com sucesso!"
    } else {
        Write-Mensagem -tipo "INFO" -texto "Operacao cancelada"
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== INFORMACOES DO SISTEMA ==========
function Info-Sistema {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                   INFORMACOES DO SISTEMA                 " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Data/Hora:      $(Get-Date)" -ForegroundColor Cyan
    Write-Host "Computador:     $env:COMPUTERNAME" -ForegroundColor Cyan
    Write-Host "Usuario:        $env:USERNAME" -ForegroundColor Cyan
    Write-Host "Diretorio:      $(Get-Location)" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Sistema:        Windows" -ForegroundColor Cyan
    Write-Host "Atividade:      $(Get-Uptime)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usuarios logados:" -ForegroundColor Cyan
    quser 2>$null | ForEach-Object { Write-Host "   $_" }
    Write-Host ""
    
    Write-Host "Espaco em disco:" -ForegroundColor Cyan
    Get-PSDrive -Name C | ForEach-Object { Write-Host "   Usado: $([math]::Round($_.Used/1GB,2)) GB de $([math]::Round($_.Free/1GB,2)) GB livre" }
    Write-Host ""
    
    Write-Host "Usuarios no script: $((Get-Content $USERS_FILE).Count) cadastrados" -ForegroundColor Cyan
    Write-Host "Total de processos no sistema: $((Get-Process).Count)" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Read-Host "Pressione ENTER para voltar"
}

# ========== CRIAR ARQUIVOS DE TESTE ==========
function Criar-Arquivos {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                   CRIACAO DE ARQUIVOS                    " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Diretorio atual: $(Get-Location)" -ForegroundColor Cyan
    Write-Host ""
    
    $qtd = Read-Host "Quantos arquivos?"
    
    if ($qtd -notmatch '^\d+$' -or $qtd -eq 0) {
        Write-Mensagem -tipo "ERRO" -texto "Numero invalido"
        Read-Host "Pressione ENTER para voltar"
        return
    }
    
    $base = Read-Host "Nome base"
    if (-not $base) { $base = "arquivo" }
    
    Write-Host ""
    Write-Host "Criando $qtd arquivo(s)..." -ForegroundColor Green
    
    for ($i = 1; $i -le $qtd; $i++) {
        $nome = "${base}_$i.txt"
        "Arquivo criado em $(Get-Date) por $env:USERNAME" | Out-File -FilePath $nome
        Write-Host "   OK: $nome"
    }
    
    Write-Mensagem -tipo "SUCESSO" -texto "$qtd arquivos criados"
    
    Write-Host ""
    Read-Host "Pressione ENTER para voltar"
}

# ========== FUNCAO PARA OBTER UPTIME ==========
function Get-Uptime {
    $uptime = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    return "$($uptime.Days) dias, $($uptime.Hours) horas, $($uptime.Minutes) minutos"
}

# ========== MENU PRINCIPAL ==========
function Mostrar-Menu {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "              SISTEMA DE GERENCIAMENTO - WINDOWS               " -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Arquivo de dados: $USERS_FILE" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "MENU PRINCIPAL" -ForegroundColor Green
    Write-Host ""
    Write-Host "   1. Informacoes do sistema"
    Write-Host "   2. Criar arquivos de teste"
    Write-Host "   3. Monitorar processos"
    Write-Host ""
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "GERENCIAMENTO DE USUARIOS " -ForegroundColor Green
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   4. LISTAR todos os usuarios (READ)"
    Write-Host "   5. CRIAR novo usuario (CREATE)"
    Write-Host "   6. EDITAR usuario (UPDATE)"
    Write-Host "   7. DELETAR usuario (DELETE)"
    Write-Host ""
    Write-Host "   8. Sair"
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
}

# ========== FUNCAO PRINCIPAL ==========
function Main {
    Inicializar-Arquivo
    
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "         SISTEMA DE GERENCIAMENTO DE USUARIOS              " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Sistema 100% FUNCIONAL sem necessidade de admin" -ForegroundColor Cyan
    Write-Host "CRUD completo de usuarios funcionando" -ForegroundColor Cyan
    Write-Host "Monitoramento de processos incluido" -ForegroundColor Cyan
    Write-Host "Dados salvos em: $USERS_FILE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Este e um sistema de simulacao local" -ForegroundColor Yellow
    Write-Host "Os usuarios sao salvos em um arquivo local, nao no sistema operacional" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pressione ENTER para comecar"
    
    while ($true) {
        Mostrar-Menu
        $opcao = Read-Host "Digite sua escolha (1-8)"
        
        switch ($opcao) {
            "1" { Info-Sistema }
            "2" { Criar-Arquivos }
            "3" { Monitorar-Processos }
            "4" { Listar-Usuarios }
            "5" { Criar-Usuario }
            "6" { Editar-Usuario }
            "7" { Deletar-Usuario }
            "8" {
                Clear-Host
                Write-Host "============================================================" -ForegroundColor Green
                Write-Host "                    SCRIPT FINALIZADO                     " -ForegroundColor Green
                Write-Host "============================================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "RESUMO FINAL:" -ForegroundColor Cyan
                Write-Host "   Arquivo de usuarios: $USERS_FILE"
                Write-Host "   Total de usuarios: $((Get-Content $USERS_FILE).Count)"
                Write-Host "   Log: $LOG_FILE"
                Write-Host ""
                Write-Host "Obrigado por usar o sistema!" -ForegroundColor Green
                exit 0
            }
            default {
                Write-Mensagem -tipo "ERRO" -texto "Opcao invalida! Digite 1-8"
                Start-Sleep -Seconds 1
            }
        }
    }
}

# ========== EXECUTAR ==========
Main
