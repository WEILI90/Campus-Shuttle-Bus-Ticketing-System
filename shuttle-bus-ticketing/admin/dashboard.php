<?php
require '../config.php';
require '../auth.php';
require_admin();

$stats = [];
$stats['bookings'] = (int)$conn->query("SELECT COUNT(*) FROM tickets")->fetch_row()[0];
$stats['revenue'] = (float)$conn->query("SELECT COALESCE(SUM(total_price), 0) FROM tickets WHERE status != 'pending'")->fetch_row()[0];
$stats['today'] = (int)$conn->query("SELECT COUNT(*) FROM tickets WHERE travel_date = CURDATE()")->fetch_row()[0];
$busiest = $conn->query("SELECT r.route_name, COALESCE(SUM(t.seat_quantity), 0) AS seats FROM routes r LEFT JOIN tickets t ON t.route_id = r.id GROUP BY r.id ORDER BY seats DESC LIMIT 1")->fetch_assoc();
$stats['busiest'] = $busiest && (int)$busiest['seats'] > 0 ? $busiest['route_name'] : 'No bookings yet';

$trend = $conn->query("SELECT travel_date, route_id, COUNT(*) AS bookings, SUM(seat_quantity) AS seats FROM tickets WHERE travel_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) GROUP BY travel_date, route_id ORDER BY travel_date, route_id")->fetch_all(MYSQLI_ASSOC);
$routes = $conn->query('SELECT id, route_name FROM routes ORDER BY route_name')->fetch_all(MYSQLI_ASSOC);
$trendByDate = [];
$maxSeats = 1;
foreach ($trend as $row) {
    $trendByDate[$row['travel_date']][(int)$row['route_id']] = (int)$row['seats'];
    $maxSeats = max($maxSeats, (int)$row['seats']);
}
$dates = [];
for ($offset = 6; $offset >= 0; $offset--) $dates[] = date('Y-m-d', strtotime("-$offset days"));

$pageTitle = 'Dashboard';
require 'partials/header.php';
?>
<div class="page-header"><h1>Operations Dashboard</h1><p>A quick read on demand, revenue and today’s bookings.</p></div>
<div class="stats-grid">
<div class="stat-card"><span class="stat-label">Total bookings</span><strong><?= $stats['bookings'] ?></strong><span class="stat-note">All ticket requests</span></div>
<div class="stat-card"><span class="stat-label">Confirmed revenue</span><strong>RM<?= number_format($stats['revenue'], 2) ?></strong><span class="stat-note">Confirmed and completed</span></div>
<div class="stat-card"><span class="stat-label">Busiest resource</span><strong class="stat-value-small"><?= htmlspecialchars($stats['busiest']) ?></strong><span class="stat-note">By seats booked</span></div>
<div class="stat-card"><span class="stat-label">Bookings today</span><strong><?= $stats['today'] ?></strong><span class="stat-note"><?= date('d M Y') ?></span></div>
</div>
<section class="dashboard-panel"><div class="section-heading"><div><h2>Demand by route</h2><p>Seats requested over the last seven travel dates.</p></div><a class="btn btn-secondary btn-small" href="tickets.php">Review tickets</a></div>
<div class="chart">
<?php foreach ($dates as $date): ?><div class="chart-column"><div class="chart-bars"><?php foreach ($routes as $route): $value = $trendByDate[$date][(int)$route['id']] ?? 0; ?><div class="chart-bar" style="height:<?= max(4, round(($value / $maxSeats) * 100)) ?>%;" title="<?= htmlspecialchars($route['route_name']) ?>: <?= $value ?> seats"></div><?php endforeach; ?></div><span><?= htmlspecialchars(date('D', strtotime($date))) ?><br><?= htmlspecialchars(date('d M', strtotime($date))) ?></span></div><?php endforeach; ?>
</div><div class="chart-legend"><?php foreach ($routes as $index => $route): ?><span><i class="legend-dot legend-<?= $index % 4 ?>"></i><?= htmlspecialchars($route['route_name']) ?></span><?php endforeach; ?></div>
</section>
<section class="dashboard-panel"><div class="section-heading"><div><h2>Booking status</h2><p>Move requests through the workflow from the Tickets page.</p></div></div><div class="status-summary"><?php foreach (['pending','confirmed','done'] as $status): $count = (int)$conn->query("SELECT COUNT(*) FROM tickets WHERE status = '$status'")->fetch_row()[0]; ?><div><span class="badge badge-<?= $status ?>"><?= ucfirst($status) ?></span><strong><?= $count ?></strong></div><?php endforeach; ?></div></section>
<?php require 'partials/footer.php'; ?>