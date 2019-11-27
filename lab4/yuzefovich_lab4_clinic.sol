pragma solidity ^0.5.11;

contract Ownable {
    
    address internal owner;
    
    modifier onlyOwner { require(msg.sender == owner, "Operation not permitted!"); _; }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
    
    function transferOwnership(address newOwner) 
        public
        onlyOwner
    {
        owner = newOwner;
    }
    
}

// owner here - clinic employee who records patients
contract Clinic is Ownable {
    
    struct Doctor {
        //address id;
        bool works;
        mapping (address => Appointment) appointments; // key - patient address, value - Appointment
    }
    
    struct Appointment {
        //address id;
        bool exists;
        Date when;
    }
    
    struct Date {
        uint day;
        uint month;
        uint year;
    }
    
    address payable private clinicAddress;
    uint private comission;
    
    Date private todayDate;
    
    mapping (address => Doctor) private doctors; // key - doctor address, value - Doctor
    
    event comissionTransfered(address patientId, uint commission);
    event AppointmentAdded(address doctorId, address patientId);
    event AppointmentCanceled(address doctorId, address patientId);
    
    modifier onlyDoctor { require(doctors[msg.sender].works, "Operation not permitted!"); _; }
    modifier correctDate(uint day, uint month, uint year) {
        require(isCorrectDate(day, month, year), "Incorrect date!"); 
        _; 
    }
    modifier onlyADayBefore(uint day, uint month, uint year) { 
        require(isADayBefore(day, month, year), "You can make/cancel appointment only a day before visit."); 
        _; 
    }
    
    constructor(address payable _clinicAddress, uint _comission) public Ownable() {
        clinicAddress = _clinicAddress;
        comission = _comission;
    }
    
    function updateTodayDate(uint _day, uint _month, uint _year) 
        public
        onlyOwner
        correctDate(_day, _month, _year)
    {
        todayDate = Date({
            day: _day,
            month: _month,
            year: _year
        });
    }
    
    function isCorrectDate(uint day, uint month, uint year) internal pure returns (bool) {
        return (day >= 1 && day <= 31)
            && (month >= 1 && month <= 12)
            && year >= 0;
    }
    
    function isADayBefore(uint day, uint month, uint year) 
        internal 
        view 
        correctDate(day, month, year)
        returns (bool) 
    {
        return year >= todayDate.year
            && month >= todayDate.month
            && day > todayDate.day;
    }
    
    function makeAppointment(
        address doctorId, 
        address patientId, 
        uint _day, uint _month, uint _year
    ) 
        public 
        payable
        onlyOwner
        onlyADayBefore(_day, _month, _year)
    {
        require(msg.value == comission, "Wrong commission transfer!");
        Doctor storage doctor = doctors[doctorId];
        require(doctor.works, "There is no doctor with this id.");
        Date memory date = Date({
            day: _day,
            month: _month,
            year: _year
        });
        doctor.appointments[patientId] = Appointment({
           exists: true,
           when: date
        });
        emit comissionTransfered(patientId, comission);
        clinicAddress.transfer(comission);
        emit AppointmentAdded(doctorId, patientId);
    }
    
    function cancelAppointment(
        address doctorId, 
        address patientId, 
        uint _day, uint _month, uint _year
    ) 
        public
        onlyOwner
        onlyADayBefore(_day, _month, _year)
    {
        Doctor storage doctor = doctors[doctorId];
        require(doctor.works, "There is no doctor with this id");
        Appointment storage appointment = doctor.appointments[patientId];
        require(appointment.exists, "This patien does't have appointment to this doctor.");
        appointment.exists = false;
        emit AppointmentCanceled(doctorId, patientId);
    }
    
    function checkAppointment(address patientId, uint day, uint month, uint year) 
        public 
        view
        onlyDoctor
        returns (bool)
    {
        Appointment storage appointment = doctors[msg.sender].appointments[patientId];
        Date storage when = appointment.when;
        return appointment.exists 
            && when.day == day
            && when.month == month
            && when.year == year;
    }
    
    function addDoctor(address doctorId)
        public
        onlyOwner
    {
        Doctor storage doctor = doctors[doctorId];
        require(!doctor.works, "This doctor is already in list.");
        doctors[doctorId] = Doctor({
            works: true
        });
    }
    
    function kill()
        public
        onlyOwner
    {
        selfdestruct(clinicAddress);
    }
    
}