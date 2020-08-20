type amt is nat;

type fa12_action is
| Transfer of (address * address * amt)
| Approve of (address * amt)
| GetAllowance of (address * address * contract(amt))
| GetBalance of (address * contract(amt))
| GetTotalSupply of (unit * contract(amt))
