import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/tracker_viewmodel.dart';
import '../models/location_reading.dart';

class TrackerPage extends StatefulWidget {
  final TrackerViewModel viewModel;

  const TrackerPage({super.key, required this.viewModel});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  @override
  void initState() {
    super.initState();
    // Add listener to rebuild when ViewModel state updates
    widget.viewModel.addListener(_onViewModelUpdate);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelUpdate);
    super.dispose();
  }

  void _onViewModelUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withAlpha(200),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Beautiful Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRACKER',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Location Analytics',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (vm.isTracking)
                        _buildStatusIndicator(
                          text: 'LIVE TRACKING',
                          color: const Color(0xFF10B981), // Emerald green
                          pulse: true,
                        )
                      else
                        _buildStatusIndicator(
                          text: 'IDLE',
                          color: Colors.amber,
                          pulse: false,
                        ),
                    ],
                  ),
                ),
              ),

              // Main Tracking Panel Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: _buildTrackingCard(context, vm),
                ),
              ),

              // Recent Location Reading & Metrics (Only show if tracking and readings exist)
              if (vm.readings.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: _buildLatestMetricsCard(
                      context,
                      vm.readings.first,
                      vm,
                    ),
                  ),
                ),

              // Filter & Clear Controls
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Location Log',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          if (vm.totalReadingsCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${vm.totalReadingsCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildFilterDropdown(context, vm),
                          const SizedBox(width: 8.0),
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_outlined),
                            tooltip: 'Clear history',
                            onPressed: vm.totalReadingsCount > 0
                                ? () => vm.clearReadings()
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Error messages, if any
              if (vm.errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: _buildErrorCard(context, vm.errorMessage!),
                  ),
                ),

              // Readings Scrollable List
              if (vm.readings.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'No logs recorded yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            vm.isTracking
                                ? 'Waiting for the first location update...'
                                : 'Toggle tracking to start capturing coordinates.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final reading = vm.readings[index];
                      return _buildReadingListItem(
                        context,
                        reading,
                        index == 0,
                      );
                    }, childCount: vm.readings.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator({
    required String text,
    required Color color,
    required bool pulse,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse)
            _PulseDot(color: color)
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6.0),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context, TrackerViewModel vm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      color: isDark
          ? Colors.grey[900]!.withOpacity(0.8)
          : Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: vm.isTracking
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    vm.isTracking
                        ? Icons.satellite_alt_outlined
                        : Icons.location_searching_outlined,
                    color: vm.isTracking
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.isTracking ? 'Target Coordinates' : 'Setup Target',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      if (vm.target != null)
                        Text(
                          'ID: ${vm.target!.id} • Lat: ${vm.target!.latitude.toStringAsFixed(4)}, Lng: ${vm.target!.longitude.toStringAsFixed(4)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        Text(
                          'Press start to fetch coordinates',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vm.isTracking
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        foregroundColor: vm.isTracking
                            ? theme.colorScheme.onError
                            : theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      onPressed: vm.isLoading
                          ? null
                          : () => vm.toggleTracking(),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  vm.isTracking
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 24,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  vm.isTracking
                                      ? 'STOP TRACKING'
                                      : 'START TRACKING',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestMetricsCard(
    BuildContext context,
    LocationReading reading,
    TrackerViewModel vm,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Display in meters if < 1000m, else switch to km
    final isKm = reading.distance >= 1000.0;
    final displayDistance = isKm
        ? '${(reading.distance / 1000.0).toStringAsFixed(3)} km'
        : '${reading.distance.toStringAsFixed(1)} m';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      color: theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.2 : 0.4),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'CURRENT DISTANCE TO TARGET',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              displayDistance,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16.0),
            Divider(color: theme.colorScheme.primary.withOpacity(0.1)),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  context,
                  title: 'Device Latitude',
                  value: reading.latitude.toStringAsFixed(5),
                ),
                _buildMetricColumn(
                  context,
                  title: 'Device Longitude',
                  value: reading.longitude.toStringAsFixed(5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(BuildContext context, TrackerViewModel vm) {
    final theme = Theme.of(context);
    final limits = [5, 10, 15, 20];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: vm.filterLimit,
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          onChanged: (int? newValue) {
            if (newValue != null) {
              vm.setFilterLimit(newValue);
            }
          },
          items: limits.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('Show $value'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingListItem(
    BuildContext context,
    LocationReading reading,
    bool isLatest,
  ) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm:ss').format(reading.timestamp);
    final dateStr = DateFormat('yyyy-MM-dd').format(reading.timestamp);

    final isKm = reading.distance >= 1000.0;
    final distanceStr = isKm
        ? '${(reading.distance / 1000.0).toStringAsFixed(3)} km'
        : '${reading.distance.toStringAsFixed(1)} m';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: isLatest
            ? theme.colorScheme.primary.withOpacity(0.05)
            : theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isLatest
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: isLatest ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Icon Column
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isLatest
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLatest ? Icons.my_location : Icons.location_on_outlined,
                size: 20,
                color: isLatest
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16.0),

            // Middle Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Lat: ${reading.latitude.toStringAsFixed(5)}, Lng: ${reading.longitude.toStringAsFixed(5)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Right Distance Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  distanceStr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isLatest
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'from target',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;

  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_controller.value * 0.7 + 0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(
                  (1.0 - _controller.value) * 0.4,
                ),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
        );
      },
    );
  }
}
