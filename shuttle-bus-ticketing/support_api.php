<?php
require 'config.php';
require 'auth.php';
require_login();
header('Content-Type: application/json');

$uid = (int)current_user_id();
$isAdmin = current_user_is_admin();
$threadId = (int)($_GET['thread_id'] ?? $_POST['thread_id'] ?? 0);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $message = trim($_POST['message'] ?? '');
    if ($message === '' || strlen($message) > 2000) {
        http_response_code(422);
        echo json_encode(['error' => 'Message must contain 1 to 2000 characters.']);
        exit;
    }
    if (!$isAdmin) {
        $stmt = $conn->prepare('INSERT IGNORE INTO support_threads (user_id) VALUES (?)');
        $stmt->bind_param('i', $uid);
        $stmt->execute();
        $stmt->close();
        $stmt = $conn->prepare('SELECT id FROM support_threads WHERE user_id = ?');
        $stmt->bind_param('i', $uid);
        $stmt->execute();
        $threadId = (int)$stmt->get_result()->fetch_assoc()['id'];
        $stmt->close();
    }
    $stmt = $conn->prepare('SELECT id FROM support_threads WHERE id = ?' . ($isAdmin ? '' : ' AND user_id = ?'));
    if ($isAdmin) $stmt->bind_param('i', $threadId); else $stmt->bind_param('ii', $threadId, $uid);
    $stmt->execute();
    $allowed = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    if (!$allowed) { http_response_code(403); echo json_encode(['error' => 'Thread not found.']); exit; }
    $stmt = $conn->prepare('INSERT INTO support_messages (thread_id, sender_user_id, message) VALUES (?, ?, ?)');
    $stmt->bind_param('iis', $threadId, $uid, $message);
    $stmt->execute();
    $stmt->close();
}

if (!$isAdmin) {
    $stmt = $conn->prepare('SELECT id, sender_user_id, message, created_at FROM support_messages WHERE thread_id = (SELECT id FROM support_threads WHERE user_id = ?) ORDER BY created_at');
    $stmt->bind_param('i', $uid);
} else {
    $stmt = $conn->prepare('SELECT id, sender_user_id, message, created_at FROM support_messages WHERE thread_id = ? ORDER BY created_at');
    $stmt->bind_param('i', $threadId);
}
$stmt->execute();
$messages = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();
echo json_encode(['thread_id' => $threadId, 'messages' => $messages]);
