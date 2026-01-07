<?php
/******************************************************
 * GameVault - Styled CRUD Demo using PHP + PDO
 * ----------------------------------------------------
 * Requirements: PHP with PDO and pdo_mysql extension.
 * Database: piscoboxdb (see SQL script below)
 ******************************************************/

$host = "localhost";
$user = "piscoboxuser";
$pass = "DevPassword123";
$dbname = "piscoboxdb";

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}

// ----------------------------------------------------
// CREATE
// ----------------------------------------------------
if (isset($_POST['create'])) {
    $sql = "INSERT INTO videogames (title, genre, platform, emoji, price, release_date)
            VALUES (:title, :genre, :platform, :emoji, :price, :release_date)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':title' => $_POST['title'],
        ':genre' => $_POST['genre'],
        ':platform' => $_POST['platform'],
        ':emoji' => $_POST['emoji'],
        ':price' => $_POST['price'],
        ':release_date' => $_POST['release_date']
    ]);
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// ----------------------------------------------------
// UPDATE
// ----------------------------------------------------
if (isset($_POST['update'])) {
    $sql = "UPDATE videogames 
            SET title = :title, genre = :genre, platform = :platform, emoji = :emoji, 
                price = :price, release_date = :release_date
            WHERE id = :id";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':title' => $_POST['title'],
        ':genre' => $_POST['genre'],
        ':platform' => $_POST['platform'],
        ':emoji' => $_POST['emoji'],
        ':price' => $_POST['price'],
        ':release_date' => $_POST['release_date'],
        ':id' => $_POST['id']
    ]);
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// ----------------------------------------------------
// DELETE
// ----------------------------------------------------
if (isset($_GET['delete'])) {
    $stmt = $conn->prepare("DELETE FROM videogames WHERE id = :id");
    $stmt->execute([':id' => intval($_GET['delete'])]);
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// ----------------------------------------------------
// READ
// ----------------------------------------------------
$stmt = $conn->query("SELECT * FROM videogames ORDER BY id DESC");
$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pisco Box - GameVault CRUD Demo (PDO)</title>
    <link rel="icon" href="/favicon.ico" type="image/x-icon">
    <link rel="icon" type="image/png" href="/favicon.png" sizes="32x32">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Source+Code+Pro:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="../piscostyle.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body>
<div class="container">
    <header class="header">
        <h1 class="logo">· GAME VAULT ·</h1>
        <p class="tagline">CRUD Demo using PHP + PDO within Pisco Box</p>
        <span class="version">Database: piscoboxdb</span>
    </header>

    <div class="content-wide">
        <!-- FORM CARD -->
        <div class="card">
            <?php 
            if (isset($_GET['edit'])): 
                $id = intval($_GET['edit']);
                $stmt = $conn->prepare("SELECT * FROM videogames WHERE id = :id");
                $stmt->execute([':id' => $id]);
                $game = $stmt->fetch(PDO::FETCH_ASSOC);
            ?>
                <h2 class="card-title"><i class="fas fa-pen"></i> Edit Game</h2>
                <form method="post" class="game-form">
                    <input type="hidden" name="id" value="<?= $game['id'] ?>">

                    <div class="form-group">
                        <label for="title">Title</label>
                        <input type="text" name="title" id="title" value="<?= htmlspecialchars($game['title']) ?>" required>
                    </div>

                    <div class="form-group">
                        <label for="genre">Genre</label>
                        <input type="text" name="genre" id="genre" value="<?= htmlspecialchars($game['genre']) ?>" required>
                    </div>

                    <div class="form-group">
                        <label for="platform">Platform</label>
                        <input type="text" name="platform" id="platform" value="<?= htmlspecialchars($game['platform']) ?>" required>
                    </div>

                    <div class="form-group">
                        <label for="emoji">Emoji</label>
                        <input type="text" name="emoji" id="emoji" value="<?= htmlspecialchars($game['emoji']) ?>">
                    </div>

                    <div class="form-group">
                        <label for="price">Price (USD)</label>
                        <input type="number" step="0.01" name="price" id="price" value="<?= htmlspecialchars($game['price']) ?>">
                    </div>

                    <div class="form-group">
                        <label for="release_date">Release Date</label>
                        <input type="date" name="release_date" id="release_date" value="<?= htmlspecialchars($game['release_date']) ?>">
                    </div>

                    <div class="form-actions">
                        <input type="submit" name="update" value="💾 Update Game" class="btn btn-update">
                    </div>
                </form>

            <?php else: ?>
                <h2 class="card-title"><i class="fas fa-plus"></i> Add New Game</h2>
                <form method="post" class="game-form">

                    <div class="form-group">
                        <label for="title">Title</label>
                        <input type="text" name="title" id="title" required>
                    </div>

                    <div class="form-group">
                        <label for="genre">Genre</label>
                        <input type="text" name="genre" id="genre" required>
                    </div>

                    <div class="form-group">
                        <label for="platform">Platform</label>
                        <input type="text" name="platform" id="platform" required>
                    </div>

                    <div class="form-group">
                        <label for="emoji">Emoji</label>
                        <input type="text" name="emoji" id="emoji">
                    </div>

                    <div class="form-group">
                        <label for="price">Price (USD)</label>
                        <input type="number" step="0.01" name="price" id="price">
                    </div>

                    <div class="form-group">
                        <label for="release_date">Release Date</label>
                        <input type="date" name="release_date" id="release_date">
                    </div>

                    <div class="form-actions">
                        <input type="submit" name="create" value="➕ Add Game" class="btn btn-create">
                    </div>
                </form>
            <?php endif; ?>
        </div>
    </div>

    <div class="content-wide">
        <!-- TABLE CARD -->
        <div class="card">
            <h2 class="card-title"><i class="fas fa-list"></i> Table Videogames</h2>
            <table border="1" cellpadding="5" style="width:100%; border-collapse:collapse; text-align:left;">
                <tr style="background-color: var(--secondary); color: var(--dark); text-align: center;">
                    <th>ID</th>
                    <th>🎮</th>
                    <th>Title</th>
                    <th>Genre</th>
                    <th>Platform</th>
                    <th>Price</th>
                    <th>Release</th>
                    <th>Actions</th>
                </tr>
                <?php foreach ($result as $row): ?>
                    <tr style="text-align: center;">
                        <td><?= $row['id'] ?></td>
                        <td><?= htmlspecialchars($row['emoji']) ?></td>
                        <td><?= htmlspecialchars($row['title']) ?></td>
                        <td><?= htmlspecialchars($row['genre']) ?></td>
                        <td><?= htmlspecialchars($row['platform']) ?></td>
                        <td>$<?= number_format($row['price'], 2) ?></td>
                        <td><?= htmlspecialchars($row['release_date']) ?></td>
                        <td>
                            <a href="?edit=<?= $row['id'] ?>" style="color:var(--info);">Edit</a> |
                            <a href="?delete=<?= $row['id'] ?>" onclick="return confirm('Are you sure?')" style="color:var(--danger);">Delete</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </table>
        </div>
    </div>

    <div class="footer">
        <p>GameVault CRUD is part of the <strong>Pisco Box</strong> demonstration environment.</p>
        <p>Made with ❤️ for developers experimenting with PHP + PDO.</p>
    </div>
</div>
</body>
</html>

<?php
$conn = null;
?>