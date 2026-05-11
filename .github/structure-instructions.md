# Copilot Instructions

## Objetivo

Gerar código simples, legível, consistente e fácil de manter.

Priorize clareza, previsibilidade e baixo acoplamento.

---

## Regras gerais

- Não adicionar comentários se possivel, comentários são sinal de codigo não claro
- Responda em português quando estiver explicando decisões.
- Antes de escrever código, descreva brevemente o que será feito quando a tarefa envolver mudança estrutural.
- Não altere arquivos, classes ou funções fora do escopo pedido.
- Não recrie arquivos inteiros quando apenas pequenas mudanças forem necessárias.
- Preserve convenções já existentes no projeto, a menos que haja um problema claro de qualidade.
- Prefira soluções simples e explícitas em vez de abstrações desnecessárias.
- Não adicionar dependências sem necessidade real.

---

## Clean Code

- Escreva código para humanos primeiro.
- Prefira nomes claros e descritivos.
- Evite nomes genéricos como `data`, `temp`, `value`, `obj`, `manager`, `helper`.
- Métodos devem ter responsabilidade única.
- Funções pequenas são preferíveis a funções longas.
- Evite níveis profundos de indentação.
- Reduza `else` quando retorno antecipado deixar o fluxo mais claro.
- Remova duplicação sempre que isso melhorar legibilidade.
- Não extraia métodos pequenos demais apenas por “purismo”.
- Comentários devem explicar intenção ou decisão de negócio, não repetir o que o código já mostra.

---

## Estrutura de código

- Uma classe deve ter responsabilidade bem definida.
- Evite classes “Deus”.
- Separe regra de negócio de infraestrutura.
- Evite espalhar lógica de negócio em controllers, rotas ou handlers.
- Prefira composição em vez de acoplamento excessivo.
- Dependências devem apontar para regras de negócio, não para detalhes de implementação.

---

## Métodos e funções

- Métodos devem idealmente fazer uma coisa.
- Evite muitos parâmetros.
- Se houver muitos parâmetros relacionados, considere objeto de entrada.
- Evite efeitos colaterais ocultos.
- O nome do método deve indicar claramente sua intenção.
- Retornos devem ser previsíveis.

---

## Tratamento de erros

- Não engolir exceções.
- Não usar `catch` vazio.
- Trate erro onde faz sentido.
- Mensagens de erro devem ser claras e úteis.
- Evite usar exceções como controle normal de fluxo.

---

## Dados e modelagem

- Modelos devem representar o domínio com clareza.
- Campos devem ter nomes explícitos.
- Evite estruturas genéricas demais.
- Validações devem ficar o mais próximo possível das regras de negócio.

---

## Legibilidade

- Prefira código explícito.
- Evite “mágica”.
- Evite encadeamentos longos e difíceis de ler.
- Evite lógica excessivamente compactada.
- Organize o código em blocos com boa separação visual.

---

## Refatoração

Ao modificar código existente:

- preserve comportamento atual;
- melhore legibilidade;
- reduza complexidade;
- não faça refatorações desnecessárias fora do escopo.

---

## Ao gerar código

Sempre priorizar:

1. clareza;
2. manutenção futura;
3. simplicidade;
4. consistência com o projeto.

Evite gerar código apenas “sofisticado”. Prefira código profissional e sustentável.