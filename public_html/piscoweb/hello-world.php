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
                <h2 class="card-title">
                    <i class="fa-solid fa-feather"></i><?php echo $_SERVER['SERVER_SOFTWARE'] ?>
                </h2>
                <p>To know the status of Apache Web Server:</p>                
                <div class="code-block">
                    <span class="prompt">~$</span> <span class="command">sudo systemctl status apache2</span>
                </div>
                
                <p>To restart Apache Web Server:</p>                
                <div class="code-block">
                    <span class="prompt">~$</span> <span class="command">sudo systemctl restart apache2</span>
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
                    <strong>Do you want to know how to set up a local domain for your VM?</strong> follow these instructions below
                </div>

                <!--  -->
                <p>
                    <h4 style="color: var(--primary);"> 
                    <i class="fa-solid fa-globe"></i> How to set up a local domain for your VM 
                    </h4>
                    First open your file <code style="color:var(--primary);">/etc/hosts</code> of your local machine, the PC/laptop that acts as the host machine.
                    <br><br>
                    You can use gedit, nano, or any text editor you have available. Remember to open <code style="color:var(--primary);">/etc/hosts</code> in administrator mode, so that you have write permission to this file.
                    <br><br>
                    The easiest way is to open the terminal and type:
                </p>
                <div class="code-block">
                    <span class="prompt">~$ </span> <span class="command">sudo nano /etc/hosts</span>
                </div>

                <p> Inside <code style="color:var(--primary);">/etc/hosts</code> you will see content similar to this: </p>
                <div class="code-block">
                    <span class="prompt">1 </span> <span class="command">127.0.0.1       localhost</span><br>
                    <span class="prompt">2 </span> <span class="command">::1             localhost ip6-localhost ip6-loopback</span><br>
                    <span class="prompt">3 </span> <span class="command">ff02::1         ip6-allnodes</span><br>
                    <span class="prompt">4 </span> <span class="command">ff02::2         ip6-allrouters</span><br>
                    <span class="prompt">5 </span> <br>
                    <span class="prompt">6 </span> 
                </div>

                <p>
                    At the end of the document, add a new line with your VM's IP address followed by the domain name you want to use.
                    In this example I use <code style="color:var(--primary);">piscobox.local</code>, but you can use whatever domain suits you<sup style="color:var(--primary);">1</sup>.
                </p>
                <div class="code-block">
                    <span class="prompt">1 </span> <span class="command">127.0.0.1       localhost</span><br>
                    <span class="prompt">2 </span> <span class="command">::1             localhost ip6-localhost ip6-loopback</span><br>
                    <span class="prompt">3 </span> <span class="command">ff02::1         ip6-allnodes</span><br>
                    <span class="prompt">4 </span> <span class="command">ff02::2         ip6-allrouters</span><br>
                    <span class="prompt">5 </span> <br>
                    <span class="prompt">6 </span> <span class="command">192.168.56.110  piscobox.local</span>
                </div>

                <p>Now save and close the document, and test it in your web browser by entering:</p>
                <div class="code-block">
                    <span class="command">http://piscobox.local</span>
                </div>

                <p>You should see the PiscoBox welcome page in your browser.</p>
                
                <br> <hr> <br>

                <p>
                    <sup style="color:var(--primary);">1</sup>As I mentioned, you can use any local domain you like for your websites. However, keep in mind that not all domains are supported by modern browsers. I recommend trying one of these: <code style="color:var(--primary);">.local</code>, <code style="color:var(--primary);">.test</code>, <code style="color:var(--primary);">.dev</code>, <code style="color:var(--primary);">.app</code> or <code style="color:var(--primary);">.internal</code>.
                </p>
                <div class="code-block">
                    <span class="command">192.168.56.110  website.local</span><br>
                    <span class="command">192.168.56.110  website.test</span><br>
                    <span class="command">192.168.56.110  website.dev</span><br>
                    <span class="command">192.168.56.110  website.app</span><br>
                    <span class="command">192.168.56.110  website.internal</span>
                </div>

                <p>You can do this with every website you install/develop on your VM.</p>
                <br>
                <p>
                    <h4 style="color: var(--primary);">
                        <i class="fa-solid fa-globe"></i> Some considerations
                    </h4>
                    <ul style="padding: 1em 0 0 1em;">
                        <li style="margin-bottom: 0.5em;"> If you need to run multiple virtual machines simultaneously, you should use a different IP address for each one.</li>
                        <li style="margin-bottom: 0.5em;"> Sometimes the IP address your VM is using might conflict with the IP address of another device on the same network. Change the VM's IP address in the Vagrantfile and then run <code style="color:var(--primary);">vagrant reload</code> </li>
                        <li style="margin-bottom: 0.5em;"> Sometimes it can also happen that the IP address used by your VM is outside the range allowed by the network. Change the VM's IP address in the Vagrantfile and then run <code style="color:var(--primary);">vagrant reload</code></li>
                        <li style="margin-bottom: 0.5em;"> If you are using an existing domain, for example: <code style="color:var(--primary);">arealdomain.com</code>, your VM will respond instead of the live server, so you'll lose access to the production website. It's better to use something like <code style="color:var(--primary);">arealdomain.com.local</code> to make it easier for you to distinguish between your development site (local) and your production site (web).</li>
                    </ul>                    
                </p>


            </div>

            <!-- PHP CARD -->
            <div class="card">
              <h2 class="card-title">
                <i class="fa-brands fa-php"></i> <?php echo "PHP " . phpversion() ?>
            </h2>
            <p>To know the status of PHP:</p>
            <div class="code-block">
                <span class="prompt">~$</span> <span class="command">sudo systemctl status php</span>
            </div>

            <p>To know the versión of PHP:</p>
            <div class="code-block">
                <span class="prompt">~$</span> <span class="command">php -v</span>
            </div>

            <p>To show complete PHP information:</p>
            <div class="code-block">
                <span class="prompt">~$</span> <span class="command">php -i</span>
            </div>

            <!-- PHP/MySQL DEMOS -->
            <h3 class="card-title" id="demos-php" style="font-size: 1.2rem; margin-top: 25px;">
                <i class="fa-solid fa-laptop-code"></i> Demos PHP/MySQL 
            </h3>

            <?php
            $directory_path = 'demos';
            $php_files = glob( './' . $directory_path . '/' . '*.php');            

            if (is_dir( $directory_path )) {
                ?>
                <p>PHP demo scripts:</p>
                <div class="info-box">
                    <strong>The PHP demos are installed!</strong> Click on the list to try them 
                </div>
                <?php
                // Decodificar el JSON a un array asociativo
                $demos = json_decode( file_get_contents($directory_path."/demos.json"), true );

                // If there are PHP files on demo/ directory, display them
                if ( $php_files ) {

                    foreach ($demos['demos-php'] as $demo) {
                        echo "<ul class='feature-list'>";
                        echo '<li><a target="_blank" href='. $directory_path.'/'.$demo['name'] .'>'. $demo['name'] .'</a><span>&nbsp;' . $demo['description'] . '</span></li>';
                        echo "</ul>";
                    }

                    ?>
                    <h3 class="card-title" id="demos-php" style="font-size: 1.2rem; margin-top: 25px;">
                        <i class="fa-solid fa-laptop-code"></i> In case you want to delete the PHP demos: 
                    </h3>                    
                    <div class="code-block">
                        <span class="comment"># Log in to the virtual machine</span><br>
                        <span class="prompt">~$</span> <span class="command">vagrant ssh</span>
                        <br><br>

                        <span class="comment"># Then, run the command to uninstall the PHP demos.</span><br>
                        <span class="comment"># This action will remove the demos/ directory and all the PHP files it contains. It will also delete the demo tables from the 'piscoboxdb' database. </span><br>                        
                        <span class="prompt">~$</span> <span class="command">piscobox uninstall demo-php</span>       
                        <br><br>

                        <span class="comment"># You will see an uninstallation notice</span><br>
                        <span class="prompt">⚠</span> <span class="command"> PHP files in public_html/piscoweb/demos will be ERASED</span><br>
                        <span class="prompt">⚠</span> <span class="command"> Demo tables will be DELETED from 'piscoboxdb' database</span>
                        <br><br>

                        <span class="comment"># Type 'y', 'yes', 's' or 'si' to confirm, and then press Enter key to proceed with the uninstallation</span><br>
                        <span class="command"> Do you want to proceed with the delete process? Y/n: y</span>
                        <br><br>

                        <span class="comment">
                            # If you prefer to cancel the uninstallation process, simply type 'n', 'no' or something else, then press the Enter key to cancel
                        </span><br>
                        <span class="command"> Do you want to proceed with the delete process? Y/n: n</span>
                        <br>
                    </div>

                    <p class="comment" style="color: var(--primary);"><i class="fa-solid fa-arrows-rotate"></i> Finally, reload this page: </p>
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
                // If there are no PHP files, display the information in the error box
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
                    <span class="comment"># Log in to the virtual machine</span><br>
                    <span class="prompt">~$</span> <span class="command">vagrant ssh</span>
                    <br><br>

                    <span class="comment"># Then, run the installation command</span><br>
                    <span class="prompt">~$</span> <span class="command">piscobox install demo-php</span>                    
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

<script>
    // Detects when the demo directory is installed or uninstalled
    const DIRECTORY = './demos/'; // Directory path to monitor
    const INTERVAL = 5000;

    let previouslyExist = null;
    let intervalId = null;

    // Start automatically
    startMonitor();

    function startMonitor() {
        // First verification
        verifyDirectory();

        // Then, it performs checks periodically
        intervalId = setInterval(verifyDirectory, INTERVAL);
    }

    function verifyDirectory() {
        const xhr = new XMLHttpRequest();
        xhr.open('POST', 'c.php', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

        xhr.onload = function () {
            if (xhr.status === 200) {
                try {
                    const data = JSON.parse(xhr.responseText);

                    if (typeof data.exist !== 'undefined') {
                        // First check
                        if (previouslyExist === null) {
                            previouslyExist = data.exist;
                            show(`Monitor active. Current status: ${data.exist ? '✅ Installed' : '❌ Not installed'}`);
                        }
                        // State change detected
                        else if (data.exist !== previouslyExist) {
                            previouslyExist = data.exist;
                            show(`⚡ CHANGE: Demos ${data.exist ? 'Installed ✅' : 'Uninstalled now ❌'}`, true);
                            location.reload();// This should actually print the section list-demos, instead of reloading the page.
                        }
                    } else if (data.error) {
                        show(`Error: ${data.error}`, false);
                    }
                } catch (e) {
                    show('Server response error', false);
                }
            } else {
                show('Error connecting to the server', false);
            }
        };

        xhr.onerror = function () {
            show('Connection error', false);
        };

        xhr.send('p=' + encodeURIComponent(DIRECTORY));
    }

    function show(message, isChange = false) {
        const hour = new Date().toLocaleTimeString();

        if (isChange) {
            console.log("change:" + hour + " " + message);
        } else {
            console.log(hour + " " + message);
        }
    }

    // Stop if needed (e.g., when closing a tab)
    window.onbeforeunload = function () {
        if (intervalId) clearInterval(intervalId);
    };
</script>

</html>
