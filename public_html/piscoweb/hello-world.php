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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
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

            <h3 class="card-title" id="demos-php" style="font-size: 1.2rem; margin-top: 25px;"><i class="fas fa-globe"></i> Demos PHP/MySQL </h3>

            <?php
            $directory_path = 'demos';

            if (is_dir($directory_path)) {
                ?>
                <p>PHP demo scripts:</p>
                <?php
                if ( is_file($directory_path.'/gamevault_mysqli.php') && is_file($directory_path.'/gamevault_pdo.php') ) {
                    ?>
                    <ul class="feature-list">
                        <li><strong>php_mysqli CRUD Table: </strong> &nbsp; <a target="_blank" href="demos/gamevault_mysqli.php"> mysqli crud table demo </a> </li>
                        <li><strong>php_pdo CRUD Table: </strong> &nbsp; <a target="_blank" href="demos/gamevault_pdo.php"> pdo crud table demo </a> </li>
                    </ul>
                    <?php
                }else{
                    ?>
                    <div class="error-box"> 
                        <strong>Oops! Looks like some files are missing 😅</strong> follow these instructions: <a href="#install-demos-php"> Installing PHP demos with PiscoBox CLI </a>
                    </div>
                    <?php
                }                 
            } else {
                ?>
                <div class="warning-box">
                    <strong>Do you want to install the PHP demos? 😊 </strong> Just follow these instructions and then <a href="#demos-php" onclick="location.reload()">reload the page</a>:
                </div>

                <p><h4 style="color: var(--primary);"> <i class="fa-solid fa-terminal"></i> Step 1: </h4> Easy installation of PHP demos with PiscoBox CLI: </p>
                <div class="code-block">
                    <span class="comment"># Enter the virtual machine</span><br>
                    <span class="prompt">$</span> <span class="command">vagrant ssh</span>
                    <br><br>

                    <span class="comment"># Then, run the installation command</span><br>
                    <span class="prompt">$</span> <span class="command">piscobox install demo-php</span>                    
                </div>

                <p class="comment"><h4 style="color: var(--primary);"><i class="fa-solid fa-arrows-rotate"></i> Step 2: </h4> Reload this page: </p>
                <span style="display: block; width:100%">
                    <a href="#demos-php" onclick="location.reload()" style="display: block; width: 100%; padding: 0.2em; font-weight: 500; font-size: 1.35em; color: var(--primary); text-align: center;"> 
                        <?php
                        if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') {
                            $url = "https://";
                        } else {
                            $url = "http://";
                        }
                        echo $url . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']; 
                        ?>
                    </a>
                </span>
                <?php
            } // en else
            ?>
        </div>

    </div>

</div>
</body>
</html>