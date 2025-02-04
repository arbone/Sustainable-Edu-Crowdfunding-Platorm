//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SustainableEduCF { //sta per "Sustainable Education CrowdFunding"
    // Variabili di stato
    uint public totalFunds; // Saldo totale raccolto
    address public manager; // Indirizzo del manager della raccolta fondi
    uint public fundraisingGoal; // Obiettivo della raccolta fondi
    uint public donorCount; // Numero totale di donatori
    bool public isFundraisingComplete; // Stato della raccolta fondi

    // Eventi per monitorare le attività
    event DonationReceived(address donor, uint amount);
    event FundraisingComplete(uint totalFunds);

    // Modificatore per limitare alcune funzioni al manager
    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can execute this function");
        _;
    }

    // Costruttore per inizializzare il contratto
    constructor(uint _goal) {
        manager = msg.sender; // Il creatore del contratto è il manager
        fundraisingGoal = _goal; // Obiettivo della raccolta fondi
        totalFunds = 0;
        donorCount = 0;
        isFundraisingComplete = false;
    }

    // Funzione per effettuare una donazione
    function donate() public payable {
        require(!isFundraisingComplete, "Fundraising is already completed");
        require(msg.value > 0, "You must donate an amount greater than zero");

        totalFunds += msg.value; // Aggiunge la donazione al totale
        donorCount++; // Incrementa il numero di donatori

        emit DonationReceived(msg.sender, msg.value);

        // Controlla se l'obiettivo è stato raggiunto
        if (totalFunds >= fundraisingGoal) {
            isFundraisingComplete = true;
            emit FundraisingComplete(totalFunds);
        }
    }

    // Funzione per il manager per prelevare i fondi
    function withdraw() public onlyManager {
        require(isFundraisingComplete, "Fundraising is not yet completed");
        require(totalFunds > 0, "No funds available for withdrawal");

        uint amount = totalFunds;
        totalFunds = 0; // Resetta il totale dopo il prelievo

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    // Funzione receive per accettare donazioni dirette
    receive() external payable {
        donate();
    }
}