# 🧪 I'm Mottu Mobile — Teste prático Flutter com PokeAPI

## Funcionalidades implementadas

- Splash screen customizada com animação e logo
- Listagem de Pokémons com paginação, scroll infinito e pull-to-refresh
- Busca local com debounce e indicador de loading
- Filtro por tipo / habilidade (navegação para lista filtrada)
- Página de detalhes do Pokémon com informações, tipos, habilidades e navegação para relacionados
- Cache local de consultas à API
- Banner global de status offline via canal nativo (Kotlin) + GetX
- Ícone do app configurado com flutter_launcher_icons
- Arquitetura MVVM utilizando GetX
- Testes unitários simples para regras de negócio

## Como rodar o projeto

1. Instalar dependências Flutter

flutter clean && flutter pub get

2. (Android)

   flutter run ou execute F5

3. (iOS)

   - Rode `pod install --repo-update` dentro de `ios/`
   - Abra `ios/Runner.xcworkspace` no Xcode e configure o Signing & Capabilities
   - Execute pelo Xcode ou `flutter run`

4. Rodar testes

   flutter test

## Arquitetura

O projeto segue a arquitetura MVVM com GetX:

- Models: `lib/data/models/`
- Views: `lib/views/` (telas e widgets)
- ViewModels / Controllers: `lib/controllers/` (GetX Controllers)
- Services: `lib/data/services/` e `lib/services/`

---
