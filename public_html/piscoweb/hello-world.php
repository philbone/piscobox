<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pisco Box - LAMP Development Environment</title>
    <!-- Standard favicon link -->
    <link rel="icon" href="/favicon.ico" type="image/x-icon">
    <!-- Optional: for better compatibility with different devices -->
    <link rel="icon" type="image/png" href="/favicon.png" sizes="32x32">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Source+Code+Pro:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="piscostyle.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>


<body>
    <div class="container">
        <header class="header">
            <h1 class="logo"> HELLO WORLD! </h1>
            <?php
            echo "<p class='tagline'>
            Welcome to " . gethostname() . "<br>";
            echo $_SERVER['HTTP_USER_AGENT'] . "</p>";
            ?>
            <span class="version">Current Version: 0.1.0</span>
        </header>

        <div class="content">

            <div class="card">
                <h2 class="card-title"><i class="fas fa-rocket"></i><?php echo $_SERVER['SERVER_SOFTWARE'] ?></h2>
                <p>To know the status of Apache Web Server:</p>                
                <div class="code-block">
                    <span class="prompt">$</span> <span class="command">sudo systemctl status apache2</span>
                </div>
                
                <p>To restart Apache Web Server:</p>                
                <div class="code-block">
                    <span class="prompt">$</span> <span class="command">sudo systemctl restart apache2</span>
                </div>
                
                <div class="info-box">
                    <strong>Note:</strong> Make sure you have Vagrant and VirtualBox/Parallels/VMware installed <a href="https://www.google.com/search?q=how+to+install+vagrant+environment+%2B+virtualbox" target="_blank">before starting.</a>
                </div>
                
                <h3 class="card-title" style="font-size: 1.2rem; margin-top: 25px;"><i class="fas fa-globe"></i> Web Access</h3>
                <p>The default site will be available at:</p>
                <div class="code-block">
                    <span class="comment"># Main URL</span><br>
                    <span class="command"> <a href="http://localhost:8080">http://localhost:8080</a></span><br><br>
                    <span class="comment"># IP Address</span><br>
                    <span class="command"> <a href="http://192.168.56.110">http://192.168.56.110</a></span><br><br>
                    <span class="comment"># If you configured a local hostname</span><br>
                    <span class="command"> <a href="http://piscobox.test">http://piscobox.test</a></span>
                </div>

                <div class="info-box">
                    <strong>Do you want to know how to set up a local domain for your VM?</strong> follow these instructions: <a href="#edit-hosts">by editing the /etc/hosts file</a>
                </div>

            </div>

            <div class="card">
              <h2 class="card-title"><i class="fas fa-rocket"></i><?php echo "PHP " . phpversion() ?></h2>
              <p>To know the status of PHP:</p>
              <div class="code-block">
                <span class="prompt">$</span> <span class="command">sudo systemctl status php</span>
            </div>

            <p>To know the versión of PHP:</p>
            <div class="code-block">
                <span class="prompt">$</span> <span class="command">php -v</span>
            </div>

            <p>To show complete PHP information:</p>
            <div class="code-block">
                <span class="prompt">$</span> <span class="command">php -i</span>
            </div>

            <h3 class="card-title" style="font-size: 1.2rem; margin-top: 25px;"><i class="fas fa-globe"></i> Demos PHP/MySQL </h3>
            <p>Some PHP demo scripts:</p>
            <ul class="feature-list">
                <li><strong>php_mysqli CRUD Table: </strong> &nbsp; <a href="#"> mysqli crud table demo </a> </li>
                <li><strong>php_pdo CRUD Table: </strong> &nbsp; <a href="#"> pdo crud table demo </a> </li>
            </ul>

        </div>

    </div>

</div>
</body>
</html>