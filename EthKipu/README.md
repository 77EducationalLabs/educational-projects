# Módule 2

In this exam, students will apply the foundational knowledge acquired in Module 2 by developing, deploying, and documenting their first complete smart contract project.

## **Why this matters**

This exam is a critical step in your journey as a Web3 developer. It’s not just about writing Solidity — it’s about writing *secure, maintainable, and well-documented* smart contracts. You'll apply best practices in development, security patterns that protect real-world protocols, and learn how to present your work professionally through GitHub.

This practical task bridges theory and application, preparing you for real-world contributions and collaborations in the Ethereum ecosystem.

### **Exam Objectives**

- Apply core Solidity concepts learned in class.
- Follow security patterns.
- Use comments and clean structure to improve contract readability and maintainability.
- Deploy a fully functional smart contract to a testnet.
- Create a GitHub repository that documents and showcases your project.

### Task Description and Requirements

Your task is to recreate the `KipuBank` smart contract with full functionality and documentation as described below.

**KipuBank Features:**

- Users can deposit native tokens (ETH) into a personal vault.
- Users can withdraw funds from their vault, but only up to a **fixed threshold** per transaction.
- The contract enforces a **global deposit cap** (`bankCap`), set during deployment.
- Internal and external interactions must follow security best practices and revert with clear custom errors if conditions aren't met.
- Events must be emitted on both deposits and successful withdrawals.
- The contract must keep track of the number of deposits and withdrawals.
- The contract must have at least an **external**, a **private**, and a **view** functions.

**Security Practices to Follow:**

- Use **custom errors** instead of `require` strings.
- Respect the **checks-effects-interactions** pattern and naming conventions.
- Use modifiers where appropriate to validate logic.
- Handle native transfers safely.
- Keep your state variables clean, readable, and well-commented.
- Add NatSpec comments for every function, error, and state variable.

### **Deliverables**

Submit the following through the platform:

1. **GitHub Repository URL**
    
    A public repo named `kipu-bank` containing:
    
    - Your smart contract code is inside a `/contracts` folder.
    - A well-structured `README.md` that includes:
        - A description of what the contract does.
        - Deployment instructions.
        - How to interact with the contract.
2. **Deployed Contract Address**
    
    On a testnet with a verified source on a block explorer.
    

This project will become part of your growing public portfolio and demonstrate your ability to deliver secure, working solutions in Web3.

## 🧱 This is your foundation.

This is not a throwaway project — it’s the **base of your Web3 developer portfolio**. Future modules will require you to add new features to this same code.

Write it like it’s going to production — because in Web3, your GitHub *is* your resume.

## Usage

### Cloning

```shell
$ git clone https://github.com/77EducationalLabs/educational-projects/
$ cd educational-projects/EthKipu
$ code .
```

### Compile

```shell
$ forge build
```

### Test
```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

> ⚠️ Do not use this code in production!
