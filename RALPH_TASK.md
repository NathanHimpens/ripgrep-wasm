Compilation de Ripgrep pour WASM/WasmTime                            │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Objectif                                                             │ │  │ │                                                                      │ │
 │ │ Compiler Ripgrep (https://github.com/BurntSushi/ripgrep) (outil de │ │
 │ │  recherche Rust) en binaire WebAssembly et l'exécuter avec           │ │
 │ │ WasmTime sur le système de fichiers local. Créer un package NPM et   │ │
 │ │  une gem Ruby pour distribuer le binaire.                            │ │
 │ │                                                                      │ │
 │ │ Prérequis                                                            │ │
 │ │                                                                      │ │
 │ │ • Rust avec rustup installé                                          │ │
 │ │ • WasmTime CLI installé                                              │ │
 │ │ • Target WASM: wasm32-wasip1 (anciennement wasm32-wasi)              │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Phase 1 : Compilation WASM                                           │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ 1.1 Installation des dépendances                                     │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ # Installer le target WASI pour Rust                                 │ │
 │ │ rustup target add wasm32-wasip1                                      │ │
 │ │ # Installer WasmTime (macOS)                                         │ │
 │ │ brew install wasmtime                                                │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ 1.2 Cloner Ripgrep                                                   │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ git clone https://github.com/BurntSushi/ripgrep.git                  │ │
 │ │ cd ripgrep                                                           │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ 1.3 Compiler pour WASI                                               │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ cargo build --release --target wasm32-wasip1                         │ │
 │ │                                                                      │ │
 │ │ Le binaire sera généré dans: target/wasm32-wasip1/release/rg.wasm    │ │
 │ │                                                                      │ │
 │ │ 1.4 Test de validation                                               │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ # Créer un fichier test                                              │ │
 │ │ echo "Hello World\nTest pattern\nAnother line" > test.txt            │ │
 │ │ # Rechercher "pattern" avec ripgrep via WasmTime                     │ │
 │ │ wasmtime --dir=. ./target/wasm32-wasip1/release/rg.wasm "pattern"    │ │
 │ │ test.txt                                                             │ │
 │ │ # Sortie attendue: Test pattern                                      │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Phase 2 : Package NPM                                                │ │
 │ │                                                                      │ │
 │ │ S'inspirer de pandoc-wasm :                                          │ │
 │ │ /Users/nathanhimpens/Documents/klara/code/pandoc-wasm/               │ │
 │ │                                                                      │ │
 │ │ Structure à créer                                                    │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ripgrep-wasm/                                                        │ │
 │ │ ├── package.json                                                     │ │
 │ │ ├── index.js           # Exporte le chemin vers rg.wasm              │ │
 │ │ ├── lib/                                                             │ │
 │ │ │   └── download.js    # Télécharge rg.wasm depuis GitHub Releases   │ │
 │ │ └── .npmignore                                                       │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Fichiers clés (inspirés de pandoc-wasm)                              │ │
 │ │                                                                      │ │
 │ │ • package.json : metadata, postinstall hook vers lib/download.js     │ │
 │ │ • index.js : exporte le chemin vers rg.wasm                          │ │
 │ │ • lib/download.js : télécharge le binaire depuis GitHub Releases     │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Phase 3 : Gem Ruby                                                   │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Structure à créer                                                    │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ripgrep-wasm/                                                        │ │
 │ │ ├── ripgrep_wasm.gemspec                                             │ │
 │ │ ├── Rakefile                                                         │ │
 │ │ └── lib/                                                             │ │
 │ │     ├── ripgrep_wasm.rb                                              │ │
 │ │     └── ripgrep_wasm/                                                │ │
 │ │         ├── version.rb                                               │ │
 │ │         └── downloader.rb                                            │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Fichiers clés (inspirés de pandoc-wasm)                              │ │
 │ │                                                                      │ │
 │ │ • ripgrep_wasm.gemspec : metadata de la gem                          │ │
 │ │ • lib/ripgrep_wasm.rb : module principal avec RipgrepWasm.path       │ │
 │ │ • lib/ripgrep_wasm/downloader.rb : télécharge le binaire depuis      │ │
 │ │   GitHub Releases                                                    │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Phase 4 : Documentation                                              │ │
 │ │                                                                      │ │
 │ │ Créer les fichiers suivants dans le repo :                           │ │
 │ │                                                                      │ │
 │ │ |Fichier        |Contenu                                        |    │ │
 │ │                                                                      │ │
 │ │ ------------------------------------------------------------------   │ │
 │ │ -|               ----------|                                         │ │
 │ │ |README.        |Documentation complète (installation, usage,   |    │ │
 │ │  d               compilation)                                        │ │
 │ │ |IMPLEMENTATION |Choix d'implémentation et trade-offs           |    │ │
 │ │  md                                                                  │ │
 │ │ |SECURITY.      |Implications de sécurité des modifications     |    │ │
 │ │  d                                                                   │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Critères de validation                                               │ │
 │ │                                                                      │ │
 │ │ 1. [x] Rust et le target wasm32-wasip1 sont installés                │ │
 │ │ 2. [x] WasmTime est installé et fonctionnel                          │ │
 │ │ 3. [x] Ripgrep est cloné depuis GitHub                               │ │
 │ │ 4. [x] Compilation réussie vers rg.wasm                              │ │
 │ │ 5. [x] Exécution réussie avec WasmTime sur un fichier local          │ │
 │ │ 6. [ ] Package NPM créé et fonctionnel                               │ │
 │ │ 7. [ ] Gem Ruby créée et fonctionnelle                               │ │
 │ │ 8. [ ] Documentation complète (README, IMPLEMENTATION, SECURITY)     │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Exemple de validation finale                                         │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ # Test WASM direct                                                   │ │
 │ │ wasmtime --dir=. rg.wasm "TODO" src/                                 │ │
 │ │ # Test via NPM (après npm install)                                   │ │
 │ │ node -e "console.log(require('./index.js'))"                         │ │
 │ │ # Test via Ruby (après installation gem)                             │ │
 │ │ ruby -e "require 'ripgrep_wasm'; puts RipgrepWasm.path"              │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Instructions Ralph                                                   │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Commits réguliers                                                    │ │
 │ │                                                                      │ │
 │ │ • Commiter après chaque étape significative (compilation             │ │
 │ │   réussie, package créé, etc.)                                       │ │
 │ │ • Utiliser des messages de commit descriptifs en français            │ │
 │ │ • Ne pas attendre la fin pour commiter                               │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Documentation des choix                                              │ │
 │ │                                                                      │ │
 │ │ • Documenter tous les trade-offs dans `IMPLEMENTATION.md` au fur     │ │
 │ │   et à mesure                                                        │ │
 │ │ • Exemples de choix à documenter :                                   │ │
 │ │   • Features Rust activées/désactivées pour WASI                     │ │
 │ │   • Problèmes de compilation rencontrés et solutions                 │ │
 │ │   • Différences avec la version native de ripgrep                    │ │
 │ │   • Limitations WASI découvertes                                     │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Progression                                                          │ │
 │ │                                                                      │ │
 │ │ • Mettre à jour .ralph/progress.md régulièrement                     │ │
 │ │ • Noter les blocages dans .ralph/errors.log                          │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ ────────────────────────────────────────                             │ │
 │ │                                                                      │ │
 │ │                                                                      │ │
 │ │ Notes importantes                                                    │ │
 │ │                                                                      │ │
 │ │ • Le flag --dir=. est obligatoire pour WasmTime (sandbox WASI)       │ │
 │ │ • Si des erreurs de compilation surviennent (mmap, etc.),            │ │
 │ │   désactiver des features avec --no-default-features                 │ │
 │ │ • Le binaire WASM ne supportera pas toutes les features de           │ │
 │ │   ripgrep natif (pas de mmap, limitations I/O)
