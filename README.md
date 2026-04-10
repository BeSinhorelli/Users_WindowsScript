# 🖥️ Sistema de Gerenciamento de Usuários - Windows

Script em PowerShell para gerenciamento de usuários e monitoramento de processos em ambientes Windows. Sistema completo de CRUD (Create, Read, Update, Delete) com interface amigável e colorida.

## 🚀 Funcionalidades

### Gerenciamento de Usuários (CRUD)
- ✅ **CREATE** - Criar novos usuários com validação de login e senha
- 📖 **READ** - Listar todos os usuários com detalhes completos
- ✏️ **UPDATE** - Editar informações de usuários existentes
- 🗑️ **DELETE** - Remover usuários do sistema

### Monitoramento de Processos
- 🔍 Monitorar processos específicos por nome
- 📊 Visualizar todos os processos do sistema
- 👤 Filtrar processos por usuário
- 💻 Identificar processos mais pesados (CPU/Memória)
- 🔄 Monitoramento em tempo real
- ⏱️ Monitoramento temporizado de processos

### Informações do Sistema
- 📅 Data/Hora e informações do computador
- 💾 Status de uso de disco
- 👥 Usuários logados no sistema
- 🔄 Total de processos em execução

### Utilitários
- 📁 Criação de arquivos de teste em massa

## 📋 Pré-requisitos

- **Windows 7/8/10/11** ou **Windows Server 2012+**
- **PowerShell 5.1 ou superior** (já incluso no Windows 10/11)
- Permissão para executar scripts PowerShell
- Nenhuma necessidade de privilégios de administrador

## 💿 Instalação

### 1. Baixar o Script
Salve o conteúdo do script em um arquivo chamado `WindowsScript.ps1`

### 2. Abrir o PowerShell na pasta do script 
```powershell
powershell.exe -ExecutionPolicy Bypass -File "WindowsScript.ps1"

