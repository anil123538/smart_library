// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract libraryManagemnet{
    address public manager;
    uint256 public deadline;
    uint public membershipfee=1 ether;

    struct Book{
        string title;
        uint price;
        bool isAvailable;

    }
    struct Borrowedbook{
        uint256 bookid;
        uint256 borrowedTime;

    }
    struct student{
        bool isMember;
        uint256 borrowedcount;
        mapping(uint=>Borrowedbook) borrowedbooks;

    }

    Book[]public books;
    mapping(address=>student)public students;

    event MembershipPurchased(address indexed student);
    event BookBorrowed(address indexed student,uint256 bookid);
    event BookReturn(address indexed student,uint bookid);
    event PenaltyCharge(address indexed student,uint256 amount);


    constructor(uint256 _deadline){
        manager=msg.sender;
        deadline=block.timestamp+_deadline;
        
    }

    modifier OnlyManager(){
        require(msg.sender==manager,"Yo didnot have the acess");
        _;
    }
    modifier OnlyMember(){
        require(students[msg.sender].isMember,"You are not the member");
        _;
    }

    function addBook(string memory _title,uint256 _price)public OnlyManager{
        books.push(Book({
            title:_title,
            price:_price,
            isAvailable:true

        }));


    }

    function becomeMember() payable public{
        require(msg.value==membershipfee,"The amount is not sufficient to become member");
        require(!students[msg.sender].isMember,"You are already a member");
        students[msg.sender].isMember=true;
        emit  MembershipPurchased(msg.sender);
    }

    function Borrowbook(uint256 bookid)public{
        require(bookid<books.length,"No book available");
        require(books[bookid].isAvailable,"The book is not available");
        require(students[msg.sender].borrowedcount<2,"Your cannot borrow more than 2 books");
        books[bookid].isAvailable=false;

        students[msg.sender].borrowedbooks[students[msg.sender].borrowedcount]=Borrowedbook({
            bookid:bookid,
            borrowedTime:block.timestamp

        });
        students[msg.sender].borrowedcount++;
        emit BookBorrowed(msg.sender, bookid);




    }
    function returnBook(uint256 index)public OnlyMember{
        require(index<students[msg.sender].borrowedcount,"invalid index mentioned");
        Borrowedbook memory borrowedBook = students[msg.sender].borrowedbooks[index];
        uint256 bookid=borrowedBook.bookid;
        require(bookid<books.length,"Invalid book id");

        //check for penalty
        if(block.timestamp>borrowedBook.borrowedTime+deadline){
            uint256 penalty=books[bookid].price;
            require(msg.sender.balance>=penalty,"No sufficient balance in your account");
            payable(manager).transfer(penalty);
            emit PenaltyCharge(msg.sender, penalty);

        }
        books[bookid].isAvailable=true;
        //shief borrowed books
        
        for(uint256 i=index;i<students[msg.sender].borrowedcount-1;i++){
            students[msg.sender].borrowedbooks[i]=students[msg.sender].borrowedbooks[i+1];


        }
        delete students[msg.sender].borrowedbooks[students[msg.sender].borrowedcount-1];
        students[msg.sender].borrowedcount--;
        emit BookReturn(msg.sender, bookid);

       



    }
    function getBooksdetails(uint bookid)public view returns(string memory title,uint256 price,bool isAvailable){
        require(bookid<books.length,"No valid book id");
        Book memory book=books[bookid];
        return(book.title,book.price,book.isAvailable);

    }
    function withdrawfunds() public OnlyManager{
        require(block.timestamp>deadline,"Its not time to withdraw the money manager");
        payable(manager).transfer(address(this).balance);
    }
    fallback() external payable { }
    receive() external payable { }

    function getbalance()public view returns(uint){
        require(msg.sender==manager,"you cannot get acess to the balance");
        return(address(this).balance);
    }


    
    

}