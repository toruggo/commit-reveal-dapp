# Commit–Reveal Voting na Sepolia

Este projeto implementa um **exemplo didático de protocolo Commit–Reveal** em uma blockchain pública (**Ethereum Sepolia**), usando:

- **Solidity + Hardhat** para o contrato;
- **ethers.js + MetaMask** em um **frontend estático** (HTML + JS) para interação.

> ⚠️ **Uso educacional**: não é adequado para votações reais nem garante anonimato forte.

## 1. Ideia do protocolo Commit–Reveal

Em vez de enviar o voto diretamente on-chain, o fluxo é dividido em duas fases:

1. **Commit (compromisso)**  
   O usuário envia apenas um **hash** do voto, sem revelá-lo:

```solidity
   keccak256(abi.encodePacked(choice, salt, msg.sender))
```

Onde:

* `choice`: opção de voto (1..maxChoice);
* `salt`: segredo aleatório gerado no frontend;
* `msg.sender`: endereço da carteira.

Propriedades:

* **Binding**: não é possível mudar o voto sem mudar o hash;
* **Hiding**: o voto não é dedutível apenas pelo hash.

2. **Reveal (revelação)**
   Após a fase de commit, o usuário envia (`choice`, `salt`).
   O contrato recomputa o hash e, se coincidir, contabiliza o voto na opção `choice`.

Ao final da fase de reveal, o contrato permite:

* Consultar o **tally** (votos por opção);
* Obter o **vencedor** e detectar **empates**.


## 2. Arquitetura do projeto

```text
commit-reveal-dapp/
├── contracts/
│   └── CommitReveal.sol        # Contrato Solidity
├── scripts/
│   └── deploy.js               # Deploy Hardhat (Sepolia)
├── frontend/
│   └── index.html              # Frontend estático c/ ethers.js
├── test/                       # (opcional) testes Hardhat
├── hardhat.config.js
├── package.json
└── .env                        # SEPOLIA_RPC_URL, PRIVATE_KEY (não versionar)
```

**Componentes principais**

* `CommitReveal.sol`

  * Define fases (`Commit`, `Reveal`, `Finished`);
  * Armazena commits, reveals, tally e calcula o vencedor.

* **Hardhat**

  * Compila e faz deploy na rede **Sepolia** usando variáveis de ambiente.

* `frontend/index.html`

  * Conecta com MetaMask (Sepolia);
  * Permite informar o **endereço do contrato**;
  * Exibe fase atual, countdown e forms de **Commit** e **Reveal**;
  * Mostra contagem de votos e resultado.

## 3. Pré-requisitos

* **Node.js** (LTS recente);
* **npm**;
* Extensão **MetaMask** configurada para a rede **Sepolia**;
* Algum **ETH de teste** na conta da MetaMask;
* Endpoint RPC Sepolia (p.ex. **Infura** ou **Alchemy**).

## 4. Setup rápido

Na raiz do projeto:

```bash
git clone <url-do-repo>
cd commit-reveal-dapp

npm install
```

Crie um arquivo `.env` com:

```env
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/SEU_PROJECT_ID
PRIVATE_KEY=0xSUA_CHAVE_PRIVADA_DA_CONTA_DE_DEPLOY
```

> ⚠️ Não faça commit desse arquivo, nem compartilhe a chave privada.

`hardhat.config.js` utiliza essas variáveis para configurar a rede `sepolia`.

## 5. Deploy do contrato na Sepolia

Script de deploy: `scripts/deploy.js`
(define, por exemplo, duração das fases e número de opções de voto).

Comandos:

```bash
# Compilar contratos
npx hardhat compile

# Deploy na Sepolia
npx hardhat run scripts/deploy.js --network sepolia
```

O script imprime no console:

```text
CommitReveal deployed to: 0x1234...ABCD
```

Anote esse **endereço do contrato** – ele será usado no frontend para a demo.

## 6. Frontend e fluxo da demo

Dentro da pasta `frontend`:

```bash
cd frontend

# Servir o index.html com um servidor estático simples
npx serve .
# (ou utilize o Live Server do VSCode)
```

Abra o endereço local indicado (ex.: `http://localhost:3000`) e siga:

1. **Conectar carteira**

   * Clique em “Conectar MetaMask” e autorize;
   * Certifique-se de estar na rede **Sepolia**.

2. **Carregar contrato**

   * Cole o endereço do contrato `CommitReveal` (ex.: `0x1234...ABCD`);
   * Clique em “Carregar contrato”;
   * A tela mostra fase atual e countdown com base nos timestamps on-chain.

3. **Commit**

   * Informe sua opção de voto (1..maxChoice);
   * O frontend gera um `salt` aleatório e envia a transação de commit;
   * Anote/guarde o `salt` exibido (ou use o botão de copiar).

4. **Reveal**

   * Durante a fase de reveal:

     * Informe a mesma opção de voto;
     * Cole o `salt` usado no commit;
     * Envie a transação de reveal.

5. **Resultados**

   * A UI permite:

     * Ver o tally por opção;
     * Consultar vencedor, número de votos e se houve empate;
     * Visualizar endereços que revelaram (eventos `Revealed`).

Para uma demo com múltiplos usuários, basta repetir o fluxo com contas diferentes (janelas anônimas, navegadores diferentes ou múltiplas contas na MetaMask).


## 7. Limitações e extensões

**Limitações** (versão didática):

* Um endereço = um voto, sem ponderação;
* Não há “reset” da votação após o deploy;
* Voto revelado fica publicamente associado ao endereço;
* Sem integração com listas de eleitores, KYC, etc.

**Possíveis extensões**:

* Votações parametrizáveis (descrições, labels para opções, etc.);
* Incentivos para garantir que eleitores façam o reveal;
* Técnicas de privacidade (por exemplo, uso de provas de conhecimento zero);
* Melhoria da UI, suporte multi-idioma, acessibilidade, etc.


## 8. Comandos essenciais (resumo)

Na raiz:

```bash
npm install
npx hardhat compile
npx hardhat run scripts/deploy.js --network sepolia
```

No frontend:

```bash
cd frontend
npx serve .
```