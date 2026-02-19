// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SchoolManagement{
    IERC20 public token;
    
    mapping(uint => uint) public lecturerSalary;
    constructor(address _token){
        token = IERC20(_token);
        lecturerSalary[400] = 300 *  (10**18);
        lecturerSalary[300] = 200 *  (10**18);
        lecturerSalary[200] = 100 *  (10**18);
        lecturerSalary[100] = 100 *  (10**18);
    }

    struct Student{
        uint id;
        string name;
        uint grade;
        uint timePaid;
    }
     struct Lecturer{
        uint id;
        string name;
        uint timePaid;
        uint salary;
        bool isPaid;
    }

    Student[] public students;
    Lecturer[] public lecturers;

    uint public studentId;
    uint public teacherId;

    uint studentTimePaid;
    uint lecturerTimePaid;


     function payfeeOnRegistration(uint _grade) public {
        uint  _amount;
        if(_grade == 400) _amount = 400 *  (10**18);
        else if(_grade == 300) _amount = 300 *  (10**18);
        else if(_grade == 200) _amount = 200 *  (10**18);
        else if(_grade == 100) _amount = 100 *  (10**18);

        require(_amount > 0, "There is no amount");
        token.transferFrom(msg.sender,address(this), _amount);
        studentTimePaid = block.timestamp;
        
 }
     
    function registerSudent(string memory _name, uint _grade) public {
        
        studentId += 1;
        Student memory student = Student(studentId, _name, _grade, studentTimePaid);
        students.push(student);
    }

  function payfeeOnLecturer(uint _grade) public {
        lecturerSalary[_grade];
        token.transfer(msg.sender, lecturerSalary[_grade]);   
        lecturerTimePaid = block.timestamp;    
    }
    function registerStaff(string memory _name, uint _grade ) public  {
        teacherId += 1;
        uint _salary = lecturerSalary[_grade];
        Lecturer memory lecturer = Lecturer(teacherId, _name, _salary,lecturerTimePaid,
        true);
        lecturers.push(lecturer);
    }


    function getAllStudent() view public returns(Student[] memory) {
        return students;
    }

     function getAllStaff() view public returns(Lecturer[] memory) {
        return lecturers;
    }
   
}