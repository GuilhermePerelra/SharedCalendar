

Markdown 1 — padrão atualizado
# Padrão de Desenvolvimento — Módulos Flutter

## Objetivo

Definir um padrão consistente para construção de módulos da aplicação, mantendo:

- previsibilidade de estrutura
- separação de responsabilidades
- facilidade de manutenção
- padronização de formulários e fluxo de dados

---

# Estrutura do módulo

Cada módulo deve seguir a estrutura:

- `models/`
  - entidades de domínio
  - serialização
  - mapeamento de dados

- `mvvm/`
  - ViewModels
  - estado da tela
  - regras de apresentação
  - comunicação com services

- `pages/`
  - telas
  - widgets específicos do módulo

- `services/`
  - persistência
  - acesso a APIs
  - consultas

---

# Responsabilidade de cada camada

## Model

Responsável por:

- representar dados
- serialização
- conversão para JSON
- conversão de JSON para objeto

Model **não deve** conter:

- lógica de UI
- acesso direto a Provider
- manipulação de widgets

---

## ViewModel

Responsável por:

- estado da tela
- regras de apresentação
- carregamento de dados
- comunicação com services
- notificação de mudanças

Padrão:

- estender `ChangeNotifier`
- expor propriedades observáveis
- expor ações públicas

Exemplo:

```dart
class InsumosViewModel extends ChangeNotifier {
  bool loading = false;
  final InsumosService service;

  InsumosViewModel(this.service);

  Future<void> adicionarInsumo(Insumo insumo) async {
    loading = true;
    notifyListeners();

    await service.salvar(insumo);

    loading = false;
    notifyListeners();
  }
}
View

Responsável por:

renderização
composição visual
captura de input
interação com ViewModel

A View não deve:

persistir dados diretamente
conter regra de negócio
realizar transformação de dados complexa
Provider

O módulo deve consumir estado via Provider.

Padrão preferencial:

Consumer<T>
context.read<T>()
context.watch<T>()
Padrão de telas

Telas de formulário devem preferencialmente usar:

StatefulWidget

Motivo:

controle do ciclo de vida
criação e descarte de TextEditingController
gerenciamento de FormState
Padrão obrigatório para formulários

Todo formulário deve utilizar:

Form
GlobalKey<FormState>
validação por campo
TextEditingController
dispose()
Exemplo base
class InsumosAddPage extends StatefulWidget {
  const InsumosAddPage({super.key});

  @override
  State<InsumosAddPage> createState() => _InsumosAddPageState();
}

class _InsumosAddPageState extends State<InsumosAddPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final categoriaController = TextEditingController();
  final estoqueMinimoController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    categoriaController.dispose();
    estoqueMinimoController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<InsumosViewModel>();

    final insumo = Insumo()
      ..nome = nomeController.text.trim()
      ..categoria = categoriaController.text.trim()
      ..estoqueMinimo =
          int.tryParse(estoqueMinimoController.text.trim()) ?? 0;

    await viewModel.adicionarInsumo(insumo);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsumosViewModel>(
      builder: (_, viewModel, __) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Campo obrigatório";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: estoqueMinimoController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Campo obrigatório";
                  }

                  if (int.tryParse(value) == null) {
                    return "Informe um número válido";
                  }

                  return null;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
Regras de validação
Campos obrigatórios

Sempre validar:

null
vazio
espaços em branco

Usar:

value == null || value.trim().isEmpty
Campos numéricos

Nunca usar int.parse() diretamente em input do usuário.

Usar:

int.tryParse()
Validação de domínio

Validações de regra de negócio podem existir:

no formulário
no ViewModel

Exemplos:

estoque mínimo não pode ser negativo
nome deve ter tamanho mínimo
categoria obrigatória
Padrão visual de campos

Os campos devem usar estilo reutilizável.

Preferência:

extrair InputDecoration
criar helper ou widget compartilhado

Exemplo:

InputDecoration campoPadrao(String label) {
  return InputDecoration(
    labelText: label,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
Fluxo correto de dados

Fluxo padrão:

UI → valida → cria model → chama ViewModel → ViewModel chama service

A View não deve chamar service diretamente.

Convenções de nomenclatura
Classes

PascalCase

Exemplo:

Insumo
InsumosViewModel
Variáveis e métodos

camelCase

Exemplo:

nomeController
adicionarInsumo
Métodos de domínio

Podem permanecer em português quando fizer sentido no contexto da aplicação.

Boas práticas obrigatórias
manter widgets pequenos
extrair partes reutilizáveis
evitar lógica dentro de build
evitar criação de objetos pesados no build
evitar TextEditingController em StatelessWidget
evitar parse direto de input

