// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract SchoolManagement {
    IERC20 public token;

    mapping(uint => uint) public lecturerSalary;
    mapping(address => uint) public gradeUsedForPayment;
    mapping(address => uint) public teacherIdentity;
    mapping(address => uint) public teacherName;

    constructor(address _token) {
        token = IERC20(_token);
        lecturerSalary[400] = 300 * (10 ** 18);
        lecturerSalary[300] = 200 * (10 ** 18);
        lecturerSalary[200] = 100 * (10 ** 18);
        lecturerSalary[100] = 100 * (10 ** 18);
    }

    struct Student {
        uint id;
        string name;
        uint grade;
        uint timePaid;
        bool isPaid;
    }

     enum StaffStatus{
            Active,
            Suspended
        }

    struct Lecturer {
        uint id;
        string name;
        uint grade;
        uint timePaid;
        uint salary;
        bool isPaid;
        address account;
        StaffStatus status;
       
    }

    Student[] public students;
    Lecturer[] public lecturers;

    uint public studentId;
    uint public teacherId;

    uint studentTimePaid;
    uint lecturerTimePaid;

    function payfeeOnRegistration(uint _grade, string memory _name) public {
        uint _amount;
        if (_grade == 400) _amount = 400 * (10 ** 18);
        else if (_grade == 300) _amount = 300 * (10 ** 18);
        else if (_grade == 200) _amount = 200 * (10 ** 18);
        else if (_grade == 100) _amount = 100 * (10 ** 18);

        require(
            _grade == 100 || _grade == 200 || _grade == 300 || _grade == 400,
            "Invalid grade"
        );

        require(msg.sender != address(0), "This address doesnt exist");

        token.transferFrom(msg.sender, address(this), _amount);

        studentTimePaid = block.timestamp;

        require(studentTimePaid > 0, "Pay fee first");

        studentId += 1;
        Student memory student = Student(
            studentId,
            _name,
            _grade,
            studentTimePaid,
            true
        );
        students.push(student);

        studentTimePaid = 0;
    }
    
    function registerStaff(uint _grade, string memory _name, address _account) public {
        require(
            _grade == 100 || _grade == 200 || _grade == 300 || _grade == 400,
            "Invalid grade"
        );
      

        teacherId += 1;

        Lecturer memory lecturer = Lecturer(
            teacherId,
            _name,
            _grade,
            0, 
            0,
            false, 
            _account,
            StaffStatus.Active
        );
        lecturers.push(lecturer);
        teacherName[_account] = _grade;
    }

    function payfeeOnLecturer(uint _id,address _address) public {
        require(_id >= 1 && _id <= lecturers.length, "Invalid lecturer ID");
        require(lecturers[_id - 1].account == _address, "Invalid lecturer address");

        Lecturer storage _lecturer = lecturers[_id - 1];
        
        lecturerTimePaid = block.timestamp;
        uint salary = lecturerSalary[_lecturer.grade];

        require(!_lecturer.isPaid, "Already paid");
        _lecturer.timePaid = lecturerTimePaid;
        _lecturer.salary = salary;
        _lecturer.isPaid = true;
        _address =  _lecturer.account;

        token.transfer(_address, salary);

        // teacher
        // bool success = 

        // require(success, "Token transfer failed");
    
    }
    
    function removeStudent(uint _id) public {
        require(_id >= 1 && _id <= students.length, "Invalid student ID");
        // students[_id - 1] = students[students.length -1];
        Student storage student = students[_id - 1];
        Student storage lastStudent = students[students.length - 1];
        student =  lastStudent;
        students.pop();
    }

    function suspendLecturer(uint _id) public{
         require(_id >= 1 && _id <= students.length, "Invalid student ID");
         Lecturer storage _lecturer = lecturers[_id - 1];
         _lecturer.status = StaffStatus.Suspended;
    }

    function getAllSuspendedLecturer() view public returns(Lecturer memory){
        for(uint i = 0; i < lecturers.length - 1; i++){
            if(lecturers[i].status == StaffStatus.Suspended){
               return lecturers[i];
            }
        }
    }

    function getAllStudent() public view returns (Student[] memory) {
        return students;
    }

    function getAllStaff() public view returns (Lecturer[] memory) {
        return lecturers;
    }

    receive() external payable {}

    fallback() external {}
}