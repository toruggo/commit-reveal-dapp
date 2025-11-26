// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Exemplo simples de protocolo Commit–Reveal
/// @notice Cada endereço pode fazer 1 commit e 1 reveal para um "voto" inteiro.
contract CommitReveal {
    enum Phase { Commit, Reveal, Finished }

    // hash comprometido: keccak256(abi.encodePacked(choice, salt, msg.sender))
    mapping(address => bytes32) public commitments;
    mapping(address => bool) public revealed;

    // guardar o voto revelado e a contagem
    mapping(address => uint256) public revealedChoice;
    mapping(uint256 => uint256) public tally;

    uint256 public commitDeadline;
    uint256 public revealDeadline;
    uint256 public maxChoice; // número máximo de opções (1..maxChoice)

    event Committed(address indexed user, bytes32 commitment);
    event Revealed(address indexed user, uint256 choice);

    constructor(
        uint256 _commitDuration,
        uint256 _revealDuration,
        uint256 _maxChoice
    ) {
        require(_maxChoice > 0, "maxChoice must be > 0");
        commitDeadline = block.timestamp + _commitDuration;
        revealDeadline = commitDeadline + _revealDuration;
        maxChoice = _maxChoice;
    }

    modifier inPhase(Phase p) {
        if (p == Phase.Commit) {
            require(block.timestamp < commitDeadline, "Commit phase over");
        } else if (p == Phase.Reveal) {
            require(block.timestamp >= commitDeadline, "Reveal not started");
            require(block.timestamp < revealDeadline, "Reveal phase over");
        } else {
            require(block.timestamp >= revealDeadline, "Not finished yet");
        }
        _;
    }

    function getPhase() public view returns (Phase) {
        if (block.timestamp < commitDeadline) {
            return Phase.Commit;
        } else if (block.timestamp < revealDeadline) {
            return Phase.Reveal;
        } else {
            return Phase.Finished;
        }
    }

    /// @notice Envia o hash commitado (commitment = keccak256(abi.encodePacked(choice, salt, msg.sender)))
    function commit(bytes32 commitment) external inPhase(Phase.Commit) {
        require(commitments[msg.sender] == bytes32(0), "Already committed");
        commitments[msg.sender] = commitment;
        emit Committed(msg.sender, commitment);
    }

    /// @notice Revela o valor e o salt para validar o commit
    function reveal(uint256 choice, bytes32 salt) external inPhase(Phase.Reveal) {
        require(!revealed[msg.sender], "Already revealed");
        require(choice >= 1 && choice <= maxChoice, "Invalid choice");

        bytes32 expected = keccak256(abi.encodePacked(choice, salt, msg.sender));
        require(commitments[msg.sender] == expected, "Invalid reveal");

        revealed[msg.sender] = true;
        revealedChoice[msg.sender] = choice;
        tally[choice] += 1;

        emit Revealed(msg.sender, choice);
    }

    /// @notice Exemplo simples: retorna o tally de um choice
    function getTally(uint256 choice) external view returns (uint256) {
        return tally[choice];
    }

    /// @notice Retorna a opcao vencedora, o número de votos dela
    ///         e se houve empate (ou seja, mais de uma opção com o mesmo número de votos).
    function getWinner()
        external
        view
        inPhase(Phase.Finished)
        returns (uint256 winner, uint256 winnerTally, bool isTie)
    {
        uint256 bestChoice = 0;
        uint256 bestTally = 0;
        uint256 tieCount = 0;

        for (uint256 c = 1; c <= maxChoice; c++) {
            uint256 votes = tally[c];

            if (votes > bestTally) {
                bestTally = votes;
                bestChoice = c;
                tieCount = 1;
            } else if (votes == bestTally && votes != 0) {
                tieCount += 1;
            }
        }

        // ninguém votou
        if (bestTally == 0) {
            return (0, 0, false);
        }

        bool hasTie = (tieCount > 1);
        return (bestChoice, bestTally, hasTie);
    }
}
