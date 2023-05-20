var express = require('express');

var router = express.Router();
var db=require('../database');
var app = express();
app.use(express.static('public'))
app.use('/css',express.static(__dirname + 'public/css'))
/* GET users listing. */
router.get('/login', function(req, res, next) {
  res.render('login-form.ejs');
});

var nodemailer = require('nodemailer');
var rand=Math.floor((Math.random() * 9000) + 1000);
var transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'evoting.blockchain69@gmail.com',
      pass: 'krkgfldepsrznxpl'
    }
  });

router.post('/login', function(req, res){
    var emailAddress = req.body.email_address;
    var password = req.body.password;

    var sql='SELECT * FROM registration WHERE email_address =? AND password =?';
    db.query(sql, [emailAddress, password], function (err, data, fields) {
        if(err) throw err
        if(data.length>0){
            req.session.loggedinUser= true;
            req.session.emailAddress= emailAddress;
            var mailOptions = {
                from: 'blockvoting@gmail.com',
                to: emailAddress,
                subject : "Please confirm your Email account",
                text : "Hello, Your otp is "+ rand	
              };
            transporter.sendMail(mailOptions, function(error, info){
                if (error) {
                  console.log(error);
                } 
                else {
                  console.log('Email sent: ' + info.response);
                }
              });
            res.render('loginverify.ejs');
            //res.redirect('/userInfo');
            // res.redirect('/blockchain');
        }else{
            res.render('login-form.ejs',{alertMsg:"Your Email Address or password is wrong"});
        }
    })

});

router.post('/loginverify', (req, res) => {
    var otp = req.body.otp;
    if (otp==rand) 
    {
        res.redirect('/form');
    }
    else 
    {
        res.render('login-form.ejs',{alertMsg:"You have entered wrong OTP "});
    }
})

module.exports = router;

