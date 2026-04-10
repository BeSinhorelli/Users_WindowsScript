# ============================================================
# SCRIPT DE GERENCIAMENTO DE USUÁRIOS - WINDOWS
# Autor: Bernardo
# Versão: 7.0 - Com Monitoramento de Processos
# ============================================================

# ========== CONFIGURAÇÕES ==========
$VERDE = "Green"
$VERMELHO = "Red"
$AMARELO = "Yellow"
$AZUL = "Cyan"
$ROXO = "Magenta"
$CIANO = "Cyan"

# Arquivo para armazenar usuários (simulação local)
$USERS_FILE = "$env:USERPROFILE\.script_usuarios.txt"
$LOG_FILE = "$env:USERPROFILE\.script_windows_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# ========== INICIALIZAR ARQUIVO DE USUÁRIOS ==========
function Inicializar-Arquivo {
    if (-not (Test-Path $USERS_FILE)) {
        # Criar arquivo com usuários de exemplo
        $conteudo = @"
joao:Joao Silva:/bin/bash:ativo
maria:Maria Santos:/bin/bash:ativo
carlos:Carlos Alberto:/bin/bash:ativo
ana:Ana Paula:/bin/bash:ativo
pedro:Pedro Lima:/bin/bash:ativo
"@
        Set-Content -Path $USERS_FILE -Value $conteudo
        Write-Host "Arquivo de usuários criado: $USERS_FILE"
    }
}

# ========== FUNÇÃO PARA LOG ==========
function Write-Log {
    param($tipo, $msg)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [$tipo] - $msg" | Out-File -FilePath $LOG_FILE -Append
}

# ========== FUNÇÃO PARA MOSTRAR MENSAGENS ==========
function Write-Mensagem {
    param($tipo, $texto)
    
    switch ($tipo) {
        "ERRO" { Write-Host "❌ $texto" -ForegroundColor Red }
        "SUCESSO" { Write-Host "✅ $texto" -ForegroundColor Green }
        "AVISO" { Write-Host "⚠️  $texto" -ForegroundColor Yellow }
        "INFO" { Write-Host "ℹ️  $texto" -ForegroundColor Cyan }
        "TITULO" { Write-Host "$texto" -ForegroundColor Cyan }
    }
    Write-Log -tipo $tipo -msg $texto
}

# ========== FUNÇÃO PARA MONITORAR PROCESSOS ==========
function Monitorar-Processos {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                 MONITORAMENTO DE PROCESSOS                " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📌 O que você quer monitorar?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   1. 🔍 Monitorar um processo específico (por nome)"
    Write-Host "   2. 📊 Ver todos os processos do sistema"
    Write-Host "   3. 👤 Ver processos de um usuário específico"
    Write-Host "   4. 💻 Ver processos mais pesados (CPU/Memória)"
    Write-Host "   5. 🔄 Monitorar processo em tempo real (top)"
    Write-Host "   6. ⏱️  Monitorar processo por tempo (ex: 10 segundos)"
    Write-Host "   7. 📋 Ver processos de um usuário do script"
    Write-Host "   8. 🔙 Voltar"
    Write-Host ""
    
    $opcao_proc = Read-Host "Escolha (1-8)"
    
    switch ($opcao_proc) {
        "1" {
            $processo = Read-Host "Digite o nome do processo (ex: powershell, chrome, notepad)"
            Write-Host ""
            Write-Host "🔍 Processos encontrados para '$processo':" -ForegroundColor Cyan
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Get-Process -Name "*$processo*" -ErrorAction SilentlyContinue | Format-Table -AutoSize
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
        }
        "2" {
            Write-Host ""
            Write-Host "📊 TODOS OS PROCESSOS DO SISTEMA:" -ForegroundColor Cyan
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Get-Process | Select-Object -First 20 | Format-Table -AutoSize
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Write-Host "Total de processos: $( (Get-Process).Count )" -ForegroundColor Cyan
        }
        "3" {
            $usuario_proc = Read-Host "Digite o nome do usuário"
            Write-Host ""
            Write-Host "👤 Processos do usuário '$usuario_proc':" -ForegroundColor Cyan
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*$usuario_proc*" } | Format-Table -AutoSize
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
        }
        "4" {
            Write-Host ""
            Write-Host "💻 TOP 10 PROCESSOS MAIS PESADOS (CPU):" -ForegroundColor Cyan
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table -AutoSize
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "💾 TOP 10 PROCESSOS MAIS PESADOS (MEMÓRIA):" -ForegroundColor Cyan
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | Format-Table -AutoSize
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
        }
        "5" {
            Write-Host ""
            Write-Host "🔄 Abrindo monitor em tempo real..." -ForegroundColor Cyan
            Write-Host "Pressione 'Ctrl+C' para sair do monitor" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            # Usando PowerShell equivalente ao top
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
                Write-Mensagem -tipo "ERRO" -texto "Tempo inválido! Usando 10 segundos"
                $tempo_mon = 10
            }
            
            Write-Host "⏱️  Monitorando '$processo_mon' por $tempo_mon segundos..." -ForegroundColor Cyan
            Write-Host ""
            
            $encontrado = $false
            for ($i = 1; $i -le $tempo_mon; $i++) {
                if (Get-Process -Name "*$processo_mon*" -ErrorAction SilentlyContinue) {
                    Write-Host "✅ [$i/$tempo_mon] Processo '$processo_mon' está em execução!" -ForegroundColor Green
                    $encontrado = $true
                } else {
                    Write-Host "⏳ [$i/$tempo_mon] Aguardando processo '$processo_mon'..." -ForegroundColor Yellow
                }
                Start-Sleep -Seconds 1
            }
            
            if ($encontrado) {
                Write-Mensagem -tipo "SUCESSO" -texto "Processo monitorado com sucesso"
            } else {
                Write-Mensagem -tipo "AVISO" -texto "Processo não encontrado durante o monitoramento"
            }
        }
        "7" {
            Write-Host ""
            Write-Host "📋 Usuários cadastrados no script:" -ForegroundColor Cyan
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            
            $usuarios = Get-Content $USERS_FILE
            $i = 1
            foreach ($linha in $usuarios) {
                $user = ($linha -split ':')[0]
                Write-Host "$i. $user"
                $i++
            }
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
            Write-Host ""
            
            $num_user = Read-Host "Digite o número do usuário para ver seus processos"
            
            if ($num_user -match '^\d+$') {
                $usuario_sistema = ($usuarios[$num_user - 1] -split ':')[0]
                if ($usuario_sistema) {
                    Write-Host ""
                    Write-Host "👤 Processos do usuário '$usuario_sistema' (no sistema real):" -ForegroundColor Cyan
                    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
                    Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*$usuario_sistema*" } | Format-Table -AutoSize
                    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
                }
            }
        }
        "8" { return }
        default { Write-Mensagem -tipo "ERRO" -texto "Opção inválida!" }
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNÇÃO PARA LISTAR TODOS OS USUÁRIOS ==========
function Listar-Usuarios {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                      LISTA DE USUÁRIOS                    " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    if ((Get-Content $USERS_FILE).Count -eq 0) {
        Write-Mensagem -tipo "AVISO" -texto "Nenhum usuário cadastrado!"
        Write-Host ""
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $total = (Get-Content $USERS_FILE).Count
    Write-Host "📊 Total de usuários: $total" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Nº  USUÁRIO          NOME COMPLETO               SHELL        STATUS" -ForegroundColor Green
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    
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
    
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host ""
    
    $escolha = Read-Host "Digite o número do usuário para ver detalhes (0 para voltar)"
    
    if ($escolha -gt 0) {
        Ver-DetalhesUsuario -num $escolha
    }
}

# ========== FUNÇÃO PARA VER DETALHES DE UM USUÁRIO ==========
function Ver-DetalhesUsuario {
    param($num)
    
    $linha = (Get-Content $USERS_FILE)[$num - 1]
    
    if (-not $linha) {
        Write-Mensagem -tipo "ERRO" -texto "Usuário não encontrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $campos = $linha -split ':'
    $user = $campos[0]
    $name = $campos[1]
    $shell = $campos[2]
    $status = $campos[3]
    
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                   DETALHES DO USUÁRIO                     " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Informações:" -ForegroundColor Cyan
    Write-Host "   Usuário: $user"
    Write-Host "   Nome completo: $name"
    Write-Host "   Shell: $shell"
    Write-Host "   Status: $(if ($status -eq 'ativo') { 'ATIVO' } else { 'BLOQUEADO' })"
    Write-Host ""
    Write-Host "📁 Diretório home simulado: C:\Users\$user" -ForegroundColor Cyan
    Write-Host "🆔 UID simulado: $((1000 + $num))" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNÇÃO PARA PERGUNTAR SIM/NÃO ==========
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

# ========== FUNÇÃO PARA CRIAR USUÁRIO ==========
function Criar-Usuario {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                     CRIAR USUÁRIO                        " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📋 REGRAS:" -ForegroundColor Cyan
    Write-Host "   - Login: letras minúsculas (a-z), números, _ e -"
    Write-Host "   - Login deve começar com letra"
    Write-Host "   - Exemplos: joao, maria_silva, user123"
    Write-Host ""
    
    # Nome de usuário
    while ($true) {
        $login = Read-Host "Login do usuário"
        $login = $login.ToLower()
        
        if ($login -notmatch '^[a-z][a-z0-9_-]*$') {
            Write-Mensagem -tipo "ERRO" -texto "Login inválido! Use apenas letras minúsculas, números, _ e -"
            continue
        }
        
        if ((Get-Content $USERS_FILE) -match "^$login:") {
            Write-Mensagem -tipo "ERRO" -texto "Usuário '$login' já existe!"
            continue
        }
        break
    }
    
    # Nome completo
    $nome_completo = Read-Host "Nome completo"
    if (-not $nome_completo) { $nome_completo = $login }
    
    # Shell
    Write-Host ""
    Write-Host "Shell disponíveis:" -ForegroundColor Cyan
    Write-Host "   1. powershell.exe"
    Write-Host "   2. cmd.exe"
    Write-Host "   3. bash.exe (WSL)"
    $shell_opcao = Read-Host "Escolha o shell (1-3) [padrão=1]"
    
    switch ($shell_opcao) {
        "2" { $shell = "cmd.exe" }
        "3" { $shell = "bash.exe" }
        default { $shell = "powershell.exe" }
    }
    
    # Senha
    Write-Host ""
    while ($true) {
        $senha = Read-Host "Senha" -AsSecureString
        $senha2 = Read-Host "Confirmar senha" -AsSecureString
        
        $senha_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))
        $senha2_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha2))
        
        if ($senha_texto -ne $senha2_texto) {
            Write-Mensagem -tipo "ERRO" -texto "Senhas não conferem!"
        } elseif ($senha_texto.Length -lt 4) {
            Write-Mensagem -tipo "ERRO" -texto "Senha muito curta (mínimo 4 caracteres)"
        } else {
            break
        }
    }
    
    # Confirmar
    Write-Host ""
    Write-Host "📝 Resumo:" -ForegroundColor Cyan
    Write-Host "   Login: $login"
    Write-Host "   Nome: $nome_completo"
    Write-Host "   Shell: $shell"
    Write-Host ""
    
    if (Confirmar-Acao "Confirmar criação do usuário?") {
        # Adiciona ao arquivo
        "$login:$nome_completo:$shell:ativo" | Out-File -FilePath $USERS_FILE -Append
        Write-Mensagem -tipo "SUCESSO" -texto "Usuário '$login' criado com sucesso!"
        
        # Salva senha em arquivo separado
        "$login:$senha_texto" | Out-File -FilePath "$env:USERPROFILE\.script_senhas.txt" -Append
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNÇÃO PARA EDITAR USUÁRIO ==========
function Editar-Usuario {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                     EDITAR USUÁRIO                       " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    if ((Get-Content $USERS_FILE).Count -eq 0) {
        Write-Mensagem -tipo "AVISO" -texto "Nenhum usuário cadastrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    # Mostrar lista
    Write-Host "📋 USUÁRIOS CADASTRADOS:" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host "Nº  LOGIN            NOME" -ForegroundColor Green
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    
    $usuarios = Get-Content $USERS_FILE
    $num = 1
    foreach ($linha in $usuarios) {
        $campos = $linha -split ':'
        $user = $campos[0]
        $name = $campos[1]
        Write-Host ("{0,-3} {1,-15} {2,-25}" -f $num, $user, $name)
        $num++
    }
    
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host ""
    
    $escolha = Read-Host "Digite o número do usuário para editar (0 para voltar)"
    
    if ($escolha -eq 0) { return }
    
    if ($escolha -notmatch '^\d+$') {
        Write-Mensagem -tipo "ERRO" -texto "Número inválido!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $linha = $usuarios[$escolha - 1]
    if (-not $linha) {
        Write-Mensagem -tipo "ERRO" -texto "Usuário não encontrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $campos = $linha -split ':'
    $old_user = $campos[0]
    $old_name = $campos[1]
    $old_shell = $campos[2]
    $old_status = $campos[3]
    
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "              EDITANDO USUÁRIO: $old_user                 " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
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
                Write-Mensagem -tipo "INFO" -texto "Usuário será BLOQUEADO"
            } else {
                $old_status = "ativo"
                Write-Mensagem -tipo "INFO" -texto "Usuário será ATIVADO"
            }
        }
        "4" {
            while ($true) {
                $nova_senha = Read-Host "Nova senha" -AsSecureString
                $confirma_senha = Read-Host "Confirmar senha" -AsSecureString
                
                $nova_senha_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($nova_senha))
                $confirma_senha_texto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirma_senha))
                
                if ($nova_senha_texto -ne $confirma_senha_texto) {
                    Write-Mensagem -tipo "ERRO" -texto "Senhas não conferem!"
                } elseif ($nova_senha_texto.Length -lt 4) {
                    Write-Mensagem -tipo "ERRO" -texto "Senha muito curta!"
                } else {
                    $senhas_file = "$env:USERPROFILE\.script_senhas.txt"
                    if (Test-Path $senhas_file) {
                        $conteudo = Get-Content $senhas_file | Where-Object { $_ -notmatch "^$old_user:" }
                        $conteudo | Set-Content $senhas_file
                    }
                    "$old_user:$nova_senha_texto" | Out-File -FilePath $senhas_file -Append
                    Write-Mensagem -tipo "SUCESSO" -texto "Senha alterada!"
                    break
                }
            }
        }
        "5" { return }
        default { Write-Mensagem -tipo "ERRO" -texto "Opção inválida!" }
    }
    
    # Salvar alterações
    if ($opcao -ge 1 -and $opcao -le 3) {
        $novaLinha = "$old_user:$old_name:$old_shell:$old_status"
        $conteudo = Get-Content $USERS_FILE
        $conteudo[$escolha - 1] = $novaLinha
        $conteudo | Set-Content $USERS_FILE
        Write-Mensagem -tipo "SUCESSO" -texto "Usuário atualizado com sucesso!"
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== FUNÇÃO PARA DELETAR USUÁRIO ==========
function Deletar-Usuario {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                    DELETAR USUÁRIO                     " -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    if ((Get-Content $USERS_FILE).Count -eq 0) {
        Write-Mensagem -tipo "AVISO" -texto "Nenhum usuário cadastrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    # Mostrar lista
    Write-Host "📋 USUÁRIOS CADASTRADOS:" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host "Nº  LOGIN            NOME                         STATUS" -ForegroundColor Green
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    
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
    
    Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host ""
    
    $escolha = Read-Host "Digite o número do usuário para DELETAR (0 para voltar)"
    
    if ($escolha -eq 0) { return }
    
    if ($escolha -notmatch '^\d+$') {
        Write-Mensagem -tipo "ERRO" -texto "Número inválido!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $linha = $usuarios[$escolha - 1]
    if (-not $linha) {
        Write-Mensagem -tipo "ERRO" -texto "Usuário não encontrado!"
        Read-Host "Pressione ENTER para continuar"
        return
    }
    
    $campos = $linha -split ':'
    $user = $campos[0]
    $name = $campos[1]
    $status = $campos[3]
    
    Write-Host ""
    Write-Host "⚠️  ATENÇÃO: Você está prestes a DELETAR o usuário '$user'" -ForegroundColor Red
    Write-Host "   Nome: $name" -ForegroundColor Cyan
    Write-Host "   Status: $status" -ForegroundColor Cyan
    Write-Host ""
    
    if (Confirmar-Acao "Tem certeza que deseja DELETAR este usuário?") {
        $conteudo = Get-Content $USERS_FILE
        $conteudo = $conteudo[0..($escolha-2)] + $conteudo[$escolha..($conteudo.Length-1)]
        $conteudo | Set-Content $USERS_FILE
        
        # Remover senha
        $senhas_file = "$env:USERPROFILE\.script_senhas.txt"
        if (Test-Path $senhas_file) {
            $conteudo_senhas = Get-Content $senhas_file | Where-Object { $_ -notmatch "^$user:" }
            $conteudo_senhas | Set-Content $senhas_file
        }
        
        Write-Mensagem -tipo "SUCESSO" -texto "Usuário '$user' foi DELETADO com sucesso!"
    } else {
        Write-Mensagem -tipo "INFO" -texto "Operação cancelada"
    }
    
    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# ========== INFORMAÇÕES DO SISTEMA ==========
function Info-Sistema {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                   INFORMAÇÕES DO SISTEMA                 " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📅 Data/Hora:      $(Get-Date)" -ForegroundColor Cyan
    Write-Host "💻 Computador:     $env:COMPUTERNAME" -ForegroundColor Cyan
    Write-Host "👤 Usuário:        $env:USERNAME" -ForegroundColor Cyan
    Write-Host "📁 Diretório:      $(Get-Location)" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🐧 Sistema:        Windows $(Get-ComputerInfo | Select-Object -ExpandProperty WindowsProductName)" -ForegroundColor Cyan
    Write-Host "⏱️  Atividade:      $(Get-Uptime)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📊 Usuários logados:" -ForegroundColor Cyan
    Get-Process -IncludeUserName | Select-Object UserName -Unique | ForEach-Object { Write-Host "   $($_.UserName)" }
    Write-Host ""
    
    Write-Host "💾 Espaço em disco:" -ForegroundColor Cyan
    Get-PSDrive -Name C | ForEach-Object { Write-Host "   Usado: $([math]::Round($_.Used/1GB,2)) GB de $([math]::Round($_.Free/1GB,2)) GB livre" }
    Write-Host ""
    
    Write-Host "👥 Usuários no script: $((Get-Content $USERS_FILE).Count) cadastrados" -ForegroundColor Cyan
    Write-Host "🔄 Total de processos no sistema: $((Get-Process).Count)" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Read-Host "Pressione ENTER para voltar"
}

# ========== CRIAR ARQUIVOS DE TESTE ==========
function Criar-Arquivos {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                   CRIAÇÃO DE ARQUIVOS                    " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📁 Diretório atual: $(Get-Location)" -ForegroundColor Cyan
    Write-Host ""
    
    $qtd = Read-Host "Quantos arquivos?"
    
    if ($qtd -notmatch '^\d+$' -or $qtd -eq 0) {
        Write-Mensagem -tipo "ERRO" -texto "Número inválido"
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
        Write-Host "   ✅ $nome"
    }
    
    Write-Mensagem -tipo "SUCESSO" -texto "$qtd arquivos criados"
    
    Write-Host ""
    Read-Host "Pressione ENTER para voltar"
}

# ========== FUNÇÃO PARA OBTER UPTIME ==========
function Get-Uptime {
    $uptime = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    return "$($uptime.Days) dias, $($uptime.Hours) horas, $($uptime.Minutes) minutos"
}

# ========== MENU PRINCIPAL ==========
function Mostrar-Menu {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "              SISTEMA DE GERENCIAMENTO - WINDOWS               " -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Arquivo de dados: $USERS_FILE" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📌 MENU PRINCIPAL" -ForegroundColor Green
    Write-Host ""
    Write-Host "   1. 🖥️  Informações do sistema"
    Write-Host "   2. 📁 Criar arquivos de teste"
    Write-Host "   3. 🔄 Monitorar processos"
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "👥 GERENCIAMENTO DE USUÁRIOS " -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   4. 📋 LISTAR todos os usuários (READ)"
    Write-Host "   5. ➕ CRIAR novo usuário (CREATE)"
    Write-Host "   6. ✏️  EDITAR usuário (UPDATE)"
    Write-Host "   7. 🗑️  DELETAR usuário (DELETE)"
    Write-Host ""
    Write-Host "   8. 🚪 Sair"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# ========== FUNÇÃO PRINCIPAL ==========
function Main {
    # Inicializar arquivo de usuários
    Inicializar-Arquivo
    
    # Tela de boas-vindas
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "         SISTEMA DE GERENCIAMENTO DE USUÁRIOS              " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Sistema 100% FUNCIONAL sem necessidade de admin" -ForegroundColor Cyan
    Write-Host "✅ CRUD completo de usuários funcionando" -ForegroundColor Cyan
    Write-Host "✅ Monitoramento de processos incluído" -ForegroundColor Cyan
    Write-Host "✅ Dados salvos em: $USERS_FILE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️  Este é um sistema de simulação local" -ForegroundColor Yellow
    Write-Host "   Os usuários são salvos em um arquivo local, não no sistema operacional" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pressione ENTER para começar"
    
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
                Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
                Write-Host "                    SCRIPT FINALIZADO                     " -ForegroundColor Green
                Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
                Write-Host ""
                Write-Host "📊 RESUMO FINAL:" -ForegroundColor Cyan
                Write-Host "   📁 Arquivo de usuários: $USERS_FILE"
                Write-Host "   👥 Total de usuários: $((Get-Content $USERS_FILE).Count)"
                Write-Host "   📝 Log: $LOG_FILE"
                Write-Host ""
                Write-Host "👋 Obrigado por usar o sistema!" -ForegroundColor Green
                exit 0
            }
            default {
                Write-Mensagem -tipo "ERRO" -texto "Opção inválida! Digite 1-8"
                Start-Sleep -Seconds 1
            }
        }
    }
}

# ========== EXECUTAR ==========
Main