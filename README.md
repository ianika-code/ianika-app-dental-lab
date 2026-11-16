# DentalLab — Flutter Desktop

Aplicativo desktop para administração de laboratório de prótese dentária, convertido do projeto WinForms/.NET 8 de referência.

## Funcionalidades

- Login local com verificação BCrypt e sessão.
- Dashboard com atalhos e contadores de dentistas, pacientes e pedidos.
- Cadastro, edição, pesquisa e exclusão lógica de dentistas e pacientes.
- Validação de CRO e CPF únicos, campos obrigatórios e relacionamento do paciente com dentista.
- Cadastro, edição, pesquisa, exclusão lógica e atualização de status dos pedidos.
- Geração automática do número do pedido (`PED-AAAAMMDD-NNNN`).
- Controle de estoque por categoria, com saldo mínimo, entradas, saídas e histórico de movimentações.
- Agenda de entregas, retornos e lembretes, com associação opcional a pedidos e dentistas e conclusão de eventos.
- Dashboard com alertas de estoque baixo e eventos previstos para os próximos sete dias.
- Banco SQLite compatível com os registros existentes; as tabelas de pacientes, pedidos, estoque e agenda são criadas de forma incremental, sem apagar os dados existentes.
- Logs em arquivo local.

## Executar

Requisitos: Flutter SDK com suporte para Windows Desktop e Visual Studio 2022 com **Desenvolvimento para desktop com C++** e Windows SDK.

```powershell
flutter pub get
flutter run -d windows
```

O administrador inicial (criado somente quando não há usuários no banco) é `admin@dentallab.local`, senha `Admin@123`.

Por padrão, o banco fica em `%LOCALAPPDATA%\DentalLab\dental-lab-db.db` e os logs em `%LOCALAPPDATA%\DentalLab\logs\dentallab.log`. Para usar outro arquivo SQLite, defina `DENTALLAB_DB_PATH` antes de iniciar o app.

## Verificação e build

```powershell
flutter analyze
flutter test
flutter build windows
```
