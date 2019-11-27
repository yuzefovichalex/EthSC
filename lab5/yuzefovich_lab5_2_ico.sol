pragma solidity ^0.5.11;

//ERC20 Token interface
interface TokenInterface {            
    function totalSupply() external view returns(uint);       
    function balanceOf(address tokenOwner) external view returns (uint);       
    function allowance(address tokenOwner, address spender) external view returns (uint);       
    function transfer(address to, uint tokens) external returns (bool);       
    function approve(address spender, uint tokens) external returns (bool);       
    function transferFrom(address from, address to, uint tokens) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
   
    address payable internal owner;
   
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    function kill() 
        external 
        onlyOwner 
    {
        selfdestruct(owner);
    }
   
}

// In this ICO used Token descripted below.
// Idea is that on Token init all tokens send to owner address,
// so when someone buy tokens, they transfer from owner address.
contract ICO is Ownable {
    
    TokenInterface private token;
    
    uint startTime;
    uint endTime;
    
    uint tokenCost;
    
    event Finalized();
    
    constructor(
        TokenInterface _token,
        uint _startTime,
        uint _endTime,
        uint _tokenCost
    ) public Ownable() {
        require(_startTime >= now, "Incorrect start time!");
        require(_endTime > _startTime, "Incorrect end time!");
        require(_tokenCost > 0, "Token cost should be greater than 0!");
        token = _token;
        startTime = _startTime;
        endTime = _endTime;
        tokenCost = _tokenCost;
    }
    
    function buyInternal(address buyer, uint payment) internal {
        require(buyer != address(0), "Can't transfer tokens to addres 0.");
        require(!isEnded(), "You can't buy tokens because ICO is ended.");
        uint amount = payment / tokenCost;
        // see above description why transferFrom()
        token.transferFrom(owner, buyer, amount);
    }
    
    function buy() public payable {
        buyInternal(msg.sender, msg.value);
    }
    
    function isEnded() public view returns (bool) {
        now >= endTime;
    }
    
    function finalize()
        public
        onlyOwner
    {
        require(isEnded(), "You can't finilize until ICO is not ended!");
        emit Finalized();
        owner.transfer(address(this).balance);
    }
    
    function() external payable { 
        buy();
    }
    
}

// Token used for this ICO
/*
contract Token is TokenInterface {
    
    string _name;
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    
    constructor() public {
        _name = "YuzefovichCoin";
        _totalSupply = 35 * 1000;
        _balances[msg.sender] = add(_balances[msg.sender], _totalSupply);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender, 
            msg.sender, 
            sub(_allowances[sender][msg.sender], amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = sub(_balances[sender], amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = add(_balances[recipient], amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

}
*/