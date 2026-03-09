-- EZPZBanking_Distributions
require "Items/SuburbsDistributions"

local deliverables = {
    ["Base.BankPreApproved"] = 4,
    ["Base.BankApprovedCardInside"] = 1,
    ["Base.CreditCard"] = 0.01
}

local distro = SuburbsDistributions
if distro and distro.all and distro.all.postbox and distro.all.postbox.items then
    local items = distro.all.postbox.items
    for mail, weight in pairs(deliverables) do
        table.insert(items, mail)
        table.insert(items, weight)
    end
end