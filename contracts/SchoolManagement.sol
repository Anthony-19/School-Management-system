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
    }
    struct Lecturer {
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
        uint _amount;
        if (_grade == 400) _amount = 400 * (10 ** 18);
        else if (_grade == 300) _amount = 300 * (10 ** 18);
        else if (_grade == 200) _amount = 200 * (10 ** 18);
        else if (_grade == 100) _amount = 100 * (10 ** 18);

        require(
            _grade == 100 || _grade == 200 || _grade == 300 || _grade == 400,
            "Invalid grade"
        );

        require(
            token.balanceOf(msg.sender) >= _amount,
            "Insufficient token balance"
        );

        // require(
        //     token.allowance(msg.sender, address(this)) >= _amount,
        //     "Not enough allowance"
        // );

        // require(_amount > 0, "There is no amount");

        // bool success = 
        token.transferFrom(msg.sender, address(this), _amount);

        // require(success, "Token transfer failed");

        studentTimePaid = block.timestamp;
    }

    function registerSudent(string memory _name, uint _grade) public {
        require(bytes(_name).length > 0, "Name required");
        require(
            _grade == 100 || _grade == 200 || _grade == 300 || _grade == 400,
            "Invalid grade"
        );
        require(studentTimePaid > 0, "Pay fee first");

        studentId += 1;
        Student memory student = Student(
            studentId,
            _name,
            _grade,
            studentTimePaid
        );
        students.push(student);

        studentTimePaid = 0;
    }

    function payfeeOnLecturer(uint _grade) public {
        uint _salary = lecturerSalary[_grade];
        require(_salary > 0, "Invalid grade");
        bool success = token.transfer(msg.sender, lecturerSalary[_grade]);

        require(success, "Token transfer failed");
        lecturerTimePaid = block.timestamp;
    }
    

    function registerStaff(string memory _name, uint _grade) public {
        require(bytes(_name).length > 0, "Name required");

        uint _salary = lecturerSalary[_grade];
        require(_salary > 0, "Invalid grade");
        require(lecturerTimePaid > 0, "Salary not paid yet");

        teacherId += 1;

        Lecturer memory lecturer = Lecturer(
            teacherId,
            _name,
            _salary,
            lecturerTimePaid,
            true
        );
        lecturers.push(lecturer);
        lecturerTimePaid = 0;
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
