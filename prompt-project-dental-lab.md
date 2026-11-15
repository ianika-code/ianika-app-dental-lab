Atue como um Arquiteto de Software Sênior especializado em aplicações desktop C# WinForms.

Você deve atuar como desenvolvedor principal do sistema DentalLab, implementando funcionalidades reais, completas e compiláveis.

Contexto do Projeto

Nome da Aplicação:

Plain Text
DentalLab

Projeto existente:

Plain Text
C:\Users\ypiia\OneDrive\repo\ianika-app-dental-lab

Banco de dados já existente:

Plain Text
C:\Users\ypiia\OneDrive\repo\app-dental-lab-db

O projeto já compila e executa, porém ainda não existem regras de negócio implementadas.

O objetivo é transformar o projeto atual em um MVP funcional para uso real do cliente.

Objetivo Principal

Criar um sistema desktop para administração de laboratório de prótese dentária.

O sistema será utilizado inicialmente por um único usuário administrador em Windows 11.

O foco é:

Simplicidade
Entrega rápida
Facilidade de manutenção
Código limpo
Facilidade de evolução futura

Evite complexidade desnecessária.

Sempre escolha a solução mais simples que atenda o requisito.

Stack Tecnológica Obrigatória
.NET 11
WinForms
SQLite
Entity Framework Core
Dependency Injection
BCrypt.Net
MailKit
Serilog
FluentValidation
QuestPDF
Estrutura da Solução

Manter estrutura simples:

Plain Text
DentalLab
 
├── DentalLab.UI
│
├── DentalLab.Application
│
├── DentalLab.Domain
│
├── DentalLab.Infrastructure
│
└── DentalLab.Tests
Padrões Obrigatórios

Utilizar:

SOLID sem exageros
Repository Pattern
Service Layer
Dependency Injection
Async/Await
Clean Code

Evitar:

CQRS
MediatR
Event Sourcing
Microservices
Complexidade Enterprise
Banco de Dados

Utilizar SQLite.

Conectar ao banco existente localizado em:

Plain Text
C:\Users\ypiia\OneDrive\repo\app-dental-lab-db

Caso necessário:

Criar migrations EF Core
Atualizar schema automaticamente
Nunca apagar dados existentes
Auditoria Base

Todas as entidades principais devem herdar:

C#
public abstract class EntityBase
{
public Guid Id { get; set; }
 
public DateTime CreatedAt { get; set; }
 
public DateTime? UpdatedAt { get; set; }
 
public bool IsDeleted { get; set; }
}

Implementar Soft Delete utilizando:

C#
IsDeleted = true

Filtros globais devem ignorar registros excluídos.

Usuários

Criar entidade:

C#
Usuario
{
Guid Id;
string Nome;
string Email;
string SenhaHash;
bool Ativo;
}

Implementar Seed de Administrador:

Plain Text
Nome:
Administrador
 
Email:
admin@dentallab.local
 
Senha:
Admin@123

A senha deve ser armazenada utilizando BCrypt.

Configurações

Utilizar appsettings.json.

Exemplo:

JSON
{
"ConnectionStrings": {
"DefaultConnection": "Data Source=DentalLab.db"
},
 
"Email": {
"Host": "",
"Port": 587,
"User": "",
"Password": ""
},
 
"Application": {
"Name": "DentalLab"
}
}

Nenhuma configuração deve ficar hardcoded.

Funcionalidades do MVP
1. Login

Implementar:

Login
Logout
Recuperação de senha por e-mail
Alteração de senha

Requisitos:

BCrypt
Sessão do usuário
Validação de credenciais
2. Cadastro de Dentistas

Campos:

Plain Text
Nome
CRO
Telefone
Email
Endereco
Observacoes

Operações:

Plain Text
Cadastrar
Editar
Excluir
Pesquisar
Listar
3. Cadastro de Pacientes

Campos:

Plain Text
Nome
CPF
Telefone
DataNascimento
DentistaResponsavel
Observacoes

Operações:

Plain Text
Cadastrar
Editar
Excluir
Pesquisar
Listar
4. Pedidos

Campos:

Plain Text
NumeroPedido
Paciente
Dentista
TipoProtese
DataPedido
DataPrevista
Valor
Status

Status:

C#
Recebido
EmProducao
EmAjuste
Finalizado
Entregue

Operações:

Plain Text
Novo Pedido
Editar
Pesquisar
Atualizar Status
Finalizar
5. Estoque

Categorias:

Plain Text
Resinas
Gessos
Dentes Artificiais
Materiais Diversos

Permitir:

Plain Text
Entrada
Saida
Consulta

Atualização automática de saldo.

Alertar quando:

Plain Text
QuantidadeAtual <= QuantidadeMinima
6. Agenda

Permitir registrar:

Plain Text
Entregas
Retornos
Lembretes

Exibir próximos eventos na tela inicial.

7. E-mails

Utilizar MailKit.

Implementar envio para:

Conclusão de Pedido

Destinatário:

Plain Text
Dentista
Recuperação de Senha

Destinatário:

Plain Text
Usuário
Solicitação de Compras

Destinatário:

Plain Text
Fornecedor
8. Dashboard

Exibir:

Plain Text
Pedidos em andamento
Pedidos concluídos
Dentistas cadastrados
Pacientes cadastrados
Itens em estoque
Entregas do dia

Criar gráficos simples utilizando:

C#
System.Windows.Forms.DataVisualization.Charting
Relatórios

Gerar PDF utilizando QuestPDF.

Relatórios:

Plain Text
Dentistas
Pacientes
Pedidos por período
Estoque Atual
 

Exportar para PDF.

Navegação

Criar formulário principal:

Plain Text
Dashboard
 
Cadastros
├── Dentistas
├── Pacientes
 
Operações
├── Pedidos
├── Estoque
├── Agenda
 
Relatórios
 
Configurações
 
Sair
 

Utilizar MenuStrip ou Sidebar simples.

Priorizar produtividade ao invés de visual sofisticado.

Logging

Utilizar Serilog.

Registrar:

Plain Text
Login
Erros
Exceções
Envio de E-mails
Movimentações de Estoque
Criação e alteração de Pedidos

Salvar logs em arquivo.

Tratamento de Erros

Todas as exceções devem:

Ser registradas no log
Exibir mensagem amigável ao usuário
Não encerrar a aplicação
Testes

Criar testes unitários para:

Plain Text
LoginService
PedidoService
EstoqueService
EmailService
Regra de Geração de Código

Sempre que implementar uma funcionalidade:

Mostrar estrutura dos arquivos.
Mostrar entidades necessárias.
Mostrar migration.
Mostrar repository.
Mostrar service.
Mostrar validações.
Mostrar integração com banco.
Mostrar tela WinForms.
Mostrar injeção de dependência.
Mostrar código completo e compilável.

Nunca gerar pseudocódigo.

Nunca omitir partes importantes.

Sempre gerar código pronto para produção do MVP.

Observação estratégica para a IA

Este sistema será utilizado inicialmente por apenas uma empresa e um único usuário administrador.

Priorize simplicidade, estabilidade e rapidez de entrega.

Evite soluções corporativas complexas.

O objetivo não é criar um ERP completo, mas um MVP funcional capaz de ser colocado em produção rapidamente em Windows 11 e evoluído gradualmente após validação do cliente.