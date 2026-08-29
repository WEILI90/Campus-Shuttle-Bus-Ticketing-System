<?php
require 'config.php';
require 'auth.php';
require_login();
$pageTitle = 'Support Chat';
require 'partials/header.php';
?>
<div class="page-header"><h1>Support Chat</h1><p>Ask the transport office about a route, ticket or booking.</p></div>
<div class="chat-card"><div id="chat-messages" class="chat-messages" aria-live="polite"><p class="form-hint">Loading conversation...</p></div><form id="chat-form" class="chat-form"><textarea id="chat-input" rows="2" maxlength="2000" placeholder="Write your message..." required></textarea><button type="submit">Send</button></form><p id="chat-error" class="alert alert-error" hidden></p></div>
<script>
(function () {
    var list = document.getElementById('chat-messages'), form = document.getElementById('chat-form'), input = document.getElementById('chat-input'), error = document.getElementById('chat-error');
    function render(data) { list.innerHTML = data.messages.length ? data.messages.map(function (m) { return '<div class="chat-message ' + (Number(m.sender_user_id) === <?= (int)current_user_id() ?> ? 'mine' : 'theirs') + '"><p>' + m.message.replace(/[&<>]/g, function (c) { return {'&':'&amp;','<':'&lt;','>':'&gt;'}[c]; }) + '</p><small>' + new Date(m.created_at.replace(' ', 'T')).toLocaleString() + '</small></div>'; }).join('') : '<p class="form-hint">Your conversation will appear here.</p>'; list.scrollTop = list.scrollHeight; }
    function load() { fetch('support_api.php').then(function (r) { return r.json(); }).then(render); }
    form.addEventListener('submit', function (e) { e.preventDefault(); error.hidden = true; var body = new URLSearchParams({message: input.value}); fetch('support_api.php', {method:'POST', body:body}).then(function (r) { return r.json(); }).then(function (data) { if (data.error) throw new Error(data.error); input.value = ''; render(data); }).catch(function (e) { error.textContent = e.message; error.hidden = false; }); });
    load(); setInterval(load, 4000);
})();
</script>
<?php require 'partials/footer.php'; ?>