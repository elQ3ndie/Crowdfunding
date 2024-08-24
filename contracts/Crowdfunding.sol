// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Crowdfunding {
    // Structure representing each crowdfunding campaign
    struct Campaign {
        string title;
        string description;
        address benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
    }
    // Mapping to store campaigns with a unique campaignId
    mapping(uint => Campaign) campaigns;

    // Counter to track campaign IDs
    uint campaignId;

    // Events
    event CampaignCreated(
        uint indexed campaignId,
        string title,
        address indexed benefactor,
        uint goal,
        uint deadline
    );
    event DonationReceived(
        uint indexed campaignId,
        address indexed donor,
        uint amount
    );
    event CampaignEnded(uint indexed campaignId, uint amountRaised);

    // Modifier to allow only the campaign's benefactor to perform certain actions
    modifier onlyBenefactor(uint _campaignId) {
        require(
            campaigns[_campaignId].benefactor == msg.sender,
            "Only the benefactor can perform this action"
        );
        _;
    }

    // Function to create a new campaign
    function createCampaign(
        string memory _title,
        string memory _description,
        address _benefactor,
        uint _goal,
        uint _duration
    ) public {
        require(_goal > 0, "Please your crowdfund goal must exceed 0");

        // Increment campaignId for each new campaign
        campaignId++;

        // Set deadline as current time + duration
        uint deadline = block.timestamp + _duration;

        // Store the new campaign in the mapping
        campaigns[campaignId] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0
        });

        // Emit event when a campaign is created
        emit CampaignCreated(campaignId, _title, _benefactor, _goal, deadline);
    }

    // Function to allow donations to a campaign
    function donateToCampaign(uint _campaignId) public payable {
        require(
            _campaignId > 0 && _campaignId <= campaignId,
            "Campaign doesn't exist"
        );

        Campaign storage campaign = campaigns[_campaignId];

        require(
            block.timestamp < campaign.deadline,
            "Campaign deadline has passed"
        );

        require(
            campaign.amountRaised < campaign.goal,
            "Campaign goal has already been reached"
        );

        // Update the amount raised by the donation
        campaign.amountRaised += msg.value;

        // Emit event for donation
        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // Function to end the campaign and transfer funds to the benefactor
    function endCampaign(uint _campaignId) public onlyBenefactor(_campaignId) {
        require(
            _campaignId > 0 && _campaignId <= campaignId,
            "Campaign doesn't exist"
        );

        Campaign storage campaign = campaigns[_campaignId];

        require(
            block.timestamp >= campaign.deadline,
            "Campaign is still ongoing"
        );

        // Transfer the raised amount to the benefactor if any amount was raised
        if (campaign.amountRaised > 0) {
            (bool success, ) = campaign.benefactor.call{
                value: campaign.amountRaised
            }("");
            require(success, "Transfer failed");
        }

        //Emit event when the campaign ends
        emit CampaignEnded(_campaignId, campaign.amountRaised);
    }
}
