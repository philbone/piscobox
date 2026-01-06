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
    <style>
        :root {
            --primary: #8B4513;
            --primary-light: #a55b2c;
            --secondary: #f4e4d4;
            --accent: #d4a76a;
            --dark: #333333;
            --light: #f8f8f8;
            --success: #4CAF50;
            --info: #2196F3;
            --warning: #ff9800;
            --danger: #f44336;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Montserrat', sans-serif;
            line-height: 1.6;
            color: var(--dark);
            background-color: var(--light);
            background-image: linear-gradient(to bottom, var(--secondary) 1%, var(--light) 100px);
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        /* Header */
        .header {
            text-align: center;
            padding: 40px 20px;
            /*background-color: var(--primary);*/
            background-color: white;
            color: var(--primary);
            border-radius: 10px;
            margin-bottom: 40px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            position: relative;
            overflow: hidden;
        }

        .header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(to right, var(--accent), var(--primary-light));
        }

        .logo {
            font-size: 3.5rem;
            font-weight: 700;
            margin-bottom: 10px;
            letter-spacing: 1px;
        }

        .tagline {
            font-size: 1.2rem;
            font-weight: 350;
            opacity: 0.9;
            margin-bottom: 20px;
            color: var(--primary);
        }

        .version {
            display: inline-block;
            background-color: var(--primary);
            color: var(--secondary);
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            margin-top: 10px;
        }

        /* Main Content */
        .content {
            display: grid;
            grid-template-columns: 1fr;
            gap: 30px;
        }

        @media (min-width: 992px) {
            .content {
                grid-template-columns: 1fr 1fr;
            }
        }

        .card {
            background-color: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            border-top: 4px solid var(--primary);
            transition: transform 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
        }

        .card-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--secondary);
            display: flex;
            align-items: center;
        }

        .card-title i {
            margin-right: 10px;
        }

        .feature-list {
            list-style-type: none;
        }

        .feature-list li {
            padding: 10px 0;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            align-items: center;
        }

        .feature-list li:last-child {
            border-bottom: none;
        }

        .feature-list li::before {
            content: "✓";
            color: var(--success);
            font-weight: bold;
            margin-right: 10px;
        }

        .highlight {
            background-color: var(--secondary);
            padding: 3px 8px;
            border-radius: 4px;
            font-family: 'Source Code Pro', monospace;
            font-weight: 500;
        }

        /* Code Blocks */
        .code-block {
            background-color: #2d2d2d;
            color: #f8f8f8;
            border-radius: 8px;
            padding: 20px;
            font-family: 'Source Code Pro', monospace;
            font-size: 0.95rem;
            margin: 15px 0;
            overflow-x: auto;
            line-height: 1.5;
        }

        .code-block .prompt {
            color: var(--accent);
            user-select: none;
        }

        .code-block .command {
            color: #fff;
        }

        .code-block .comment {
            color: #888;
        }

        .code-block .command a{
            color: #fff;
            text-decoration: none;
        }

        /* Info Boxes */
        .info-box {
            background-color: #e7f3ff;
            border-left: 4px solid var(--info);
            padding: 15px;
            border-radius: 4px;
            margin: 15px 0;
        }

        .warning-box {
            background-color: #fff8e1;
            border-left: 4px solid var(--warning);
            padding: 15px;
            border-radius: 4px;
            margin: 15px 0;
        }

        .success-box {
            background-color: #e8f5e9;
            border-left: 4px solid var(--success);
            padding: 15px;
            border-radius: 4px;
            margin: 15px 0;
        }

        /* Footer */
        .footer {
            text-align: center;
            margin-top: 50px;
            padding: 30px 0;
            border-top: 1px solid #eee;
            color: #777;
            font-size: 0.9rem;
        }

        .repo-link {
            display: inline-flex;
            align-items: center;
            background-color: var(--primary);
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.3s;
            margin-top: 15px;
        }

        .repo-link:hover {
            background-color: var(--primary-light);
        }

        .repo-link i {
            margin-right: 8px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .logo {
                font-size: 2.5rem;
            }
            
            .card {
                padding: 20px;
            }
            
            .container {
                padding: 15px;
            }
        }
    </style>
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