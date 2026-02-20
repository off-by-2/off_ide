import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:off_ide/off_ide.dart';
import 'package:path_provider/path_provider.dart';

// Theme Constants
const kPrimaryColor = Color(0xFF1A3B2A); // Dark Green
const kAccentColor = Color(0xFFE8F5E9); // Mint Green
const kSurfaceColor = Color(0xFFF5F5F5); // Pale Grey

// Typography
const kFontHeader = TextStyle(
  fontFamily: 'Serif', // Fallback to compatible serif
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
  runApp(const OffIdeExampleApp());
}

class OffIdeExampleApp extends StatelessWidget {
  const OffIdeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Off IDE Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          surface: kSurfaceColor,
          primary: kPrimaryColor,
        ),
        useMaterial3: true,
        fontFamily: 'Sans-Serif', // Default body font
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
      ),
      home: WorkspaceShell(
        config: WorkspaceConfig(
          maxTabs: 10,
          activityBarItems: [
            const ActivityBarItem(
              id: 'documents',
              icon: Icons.description_outlined,
              label: 'Documents',
              tooltip: 'Clinical Documentation',
            ),
            const ActivityBarItem(
              id: 'people',
              icon: Icons.people_outline,
              label: 'People',
              tooltip: 'Staff & Residents',
            ),
            const ActivityBarItem(
              id: 'analytics',
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              tooltip: 'Reports & Census',
            ),
            const ActivityBarItem(
              id: 'settings',
              icon: Icons.settings_outlined,
              label: 'Settings',
              tooltip: 'System Configuration',
            ),
          ],
          sidebarViews: {
            'documents': const SidebarView(
              id: 'documents',
              title: 'EXPLORER',
              groups: [
                MenuGroup(
                  id: 'orchard_health',
                  label: 'Orchard_Health_Corp',
                  isExpanded: true,
                  subGroups: [
                    MenuSubGroup(
                      id: 'north_region',
                      label: 'North_Region',
                      isExpanded: true,
                      items: [
                        MenuItem(
                          id: 'clinical_staff',
                          label: 'Clinical_Staff.staff',
                          pageId: 'staff-management',
                          icon: Icons.people,
                        ),
                        MenuItem(
                          id: 'resident_census',
                          label: 'Resident_Census.census',
                          pageId: 'resident-census',
                          icon: Icons.bar_chart,
                        ),
                        MenuItem(
                          id: 'facility_map',
                          label: 'Facility_Map.geo',
                          pageId: 'facility-map',
                          icon: Icons.map,
                        ),
                      ],
                    ),
                    MenuSubGroup(
                      id: 'south_region',
                      label: 'South_Region',
                      isExpanded: false,
                      // Actionable Group with Dashboard
                      pageId: 'south-region-dash',
                      items: [
                        MenuItem(
                          id: 'shift_schedule',
                          label: 'Shift_Schedule.cal',
                          pageId: 'shift-scheduler',
                          icon: Icons.calendar_month,
                        ),
                        MenuItem(
                          id: 'inventory',
                          label: 'Inventory_Log.inv',
                          pageId: 'inventory',
                          icon: Icons.inventory,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            'people': const SidebarView(
              title: 'PEOPLE',
              id: 'people',
              groups: [],
              childBuilder: _buildPeopleSidebar,
            ),
            'analytics': const SidebarView(
              title: 'ANALYTICS',
              id: 'analytics',
              groups: [],
              childBuilder: _buildPeopleSidebar, // Using same dummy for demo
            ),
            'settings': const SidebarView(
              title: 'SETTINGS',
              id: 'settings',
              groups: [],
            ),
          },
          pageRegistry: {
            'staff-management': (context, args) => const StaffManagementPage(),
            'resident-census': (context, args) => const ResidentCensusPage(),
            'facility-map': (context, args) => const FacilityMapPage(),
            'shift-scheduler': (context, args) => const ShiftSchedulerPage(),
            'south-region-dash': (context, args) => Container(
              color: Colors.orange.shade50,
              child: const Center(
                child: Text(
                  'South Region Dashboard\n(Actionable Group Demo)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            'inventory': (context, args) => Container(
              color: Colors.blue.shade50,
              child: const Center(child: Text('Inventory Placeholder')),
            ),
          },
        ),
      ),
    );
  }

  static Widget _buildPeopleSidebar(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Text('JD')),
          title: const Text('John Doe'),
          subtitle: const Text('Administrator'),
          onTap: () {},
        ),
        ListTile(
          leading: const CircleAvatar(child: Text('AS')),
          title: const Text('Alice Smith'),
          subtitle: const Text('RN - Lead'),
          onTap: () {},
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 1. Staff Management Page (Rich List)
// -----------------------------------------------------------------------------
class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff Management',
                    style: kFontHeader.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Showing all active clinicians in North Region',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: const BorderSide(color: kPrimaryColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Export PDF'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Rich Table
          Expanded(
            child: Card(
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: _staffList.length + 1, // +1 for header
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == 0) return _buildTableHeader();
                  return _buildStaffRow(context, _staffList[index - 1]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'SHIFT GROUP',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'STATUS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffRow(BuildContext context, Map<String, dynamic> staff) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Name with Avatar
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: staff['avatarColor'] as Color,
                    foregroundColor: kPrimaryColor,
                    child: Text(staff['initials'] as String),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    staff['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Role
            Expanded(
              flex: 2,
              child: Text(
                staff['role'] as String,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            // Shift Group
            Expanded(flex: 2, child: Text(staff['shift'] as String)),
            // Status Badge
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (staff['active'] as bool)
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (staff['status'] as String).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (staff['active'] as bool)
                        ? Colors.green[800]
                        : Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final List<Map<String, dynamic>> _staffList = [
    {
      'name': 'Emily Richardson',
      'initials': 'ER',
      'avatarColor': const Color(0xFFE0F2F1),
      'role': 'RN / Clinical Lead',
      'shift': 'Morning / High Care',
      'status': 'Active',
      'active': true,
    },
    {
      'name': 'Marcus Vane',
      'initials': 'MV',
      'avatarColor': const Color(0xFFFFF3E0),
      'role': 'LPN',
      'shift': 'Post-Acute',
      'status': 'Active',
      'active': true,
    },
    {
      'name': 'Sarah Jenkins',
      'initials': 'SJ',
      'avatarColor': const Color(0xFFE3F2FD),
      'role': 'CNA',
      'shift': 'Dementia Care',
      'status': 'Off-Shift',
      'active': false,
    },
    {
      'name': 'Dr. Alan Grant',
      'initials': 'AG',
      'avatarColor': const Color(0xFFF3E5F5),
      'role': 'Medical Director',
      'shift': 'On Call',
      'status': 'Active',
      'active': true,
    },
  ];
}

// -----------------------------------------------------------------------------
// 2. Resident Census Page (Analytical Grid)
// -----------------------------------------------------------------------------
class ResidentCensusPage extends StatelessWidget {
  const ResidentCensusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resident Census', style: kFontHeader.copyWith(fontSize: 32)),
          const SizedBox(height: 24),

          // KPI Cards
          Row(
            children: [
              _buildKPICard(
                'Total Residents',
                '142',
                '+3 this week',
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildKPICard(
                'Occupancy Rate',
                '94%',
                '2 beds available',
                Icons.bed,
                Colors.green,
              ),
              const SizedBox(width: 24),
              _buildKPICard(
                'Acuity Index',
                'High',
                'Level 4 Avg',
                Icons.monitor_heart,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search residents...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const DropdownMenu<String>(
                initialSelection: 'All Units',
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: 'All Units', label: 'All Units'),
                  DropdownMenuEntry(value: 'North Wing', label: 'North Wing'),
                  DropdownMenuEntry(value: 'Memory Care', label: 'Memory Care'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return _buildResidentCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    String subtext,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(icon, color: color),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResidentCard(int index) {
    final status = index % 3 == 0
        ? 'In Therapy'
        : (index % 2 == 0 ? 'Resting' : 'Activity Room');
    final color = index % 3 == 0
        ? Colors.blue
        : (index % 2 == 0 ? Colors.green : Colors.orange);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Text('R$index'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resident #10$index',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Room 304-A',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. Facility Map Page (Interactive Canvas)
// -----------------------------------------------------------------------------
class FacilityMapPage extends StatelessWidget {
  const FacilityMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Facility Map - North Wing',
                style: kFontHeader.copyWith(fontSize: 32),
              ),
              Row(
                children: [
                  _buildLegendItem('Occupied', Colors.green),
                  const SizedBox(width: 16),
                  _buildLegendItem('Vacant', Colors.grey),
                  const SizedBox(width: 16),
                  _buildLegendItem('Maintenance', Colors.red),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              color: const Color(0xFFF9F9F9),
              child: Center(
                child: CustomPaint(
                  size: const Size(600, 400),
                  painter: _MapPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Corridor
    paint.color = Colors.grey[300]!;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - 40, size.width, 80),
      paint,
    );

    // Rooms Top
    paint.color = Colors.green[100]!;
    for (int i = 0; i < 5; i++) {
      // Room
      canvas.drawRect(Rect.fromLTWH(i * 120 + 10.0, 10.0, 100, 120), paint);
      // Door
      canvas.drawLine(
        Offset(i * 120 + 60.0, 130.0),
        Offset(i * 120 + 60.0, 150.0), // Connecting to corridor
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      );
    }

    // Rooms Bottom
    paint.color = Colors.red[100]!;
    for (int i = 0; i < 5; i++) {
      if (i == 2) paint.color = Colors.grey[200]!; // Vacant
      canvas.drawRect(
        Rect.fromLTWH(i * 120 + 10.0, size.height - 130, 100, 120),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// 4. Shift Scheduler Page (Complex Layout)
// -----------------------------------------------------------------------------
class ShiftSchedulerPage extends StatelessWidget {
  const ShiftSchedulerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shift Scheduler',
                style: kFontHeader.copyWith(fontSize: 32),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'day', label: Text('Day')),
                  ButtonSegment(value: 'week', label: Text('Week')),
                  ButtonSegment(value: 'month', label: Text('Month')),
                ],
                selected: const {'week'},
                onSelectionChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                // Resource List
                SizedBox(
                  width: 250,
                  child: Card(
                    child: ListView.builder(
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person, size: 16),
                          ),
                          title: Text('Staff Member ${index + 1}'),
                          subtitle: Text(index % 2 == 0 ? 'RN' : 'CNA'),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Calendar Grid (Mockup for complexity)
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        // Days Header
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: List.generate(
                              7,
                              (index) => Expanded(
                                child: Center(
                                  child: Text(
                                    'Day ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Grid
                        Expanded(
                          child: Row(
                            children: List.generate(7, (dayIndex) {
                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      if (dayIndex == 1)
                                        Positioned(
                                          top: 50,
                                          left: 5,
                                          right: 5,
                                          height: 60,
                                          child: _buildShiftBlock(
                                            'Morning Round',
                                            Colors.blue,
                                          ),
                                        ),
                                      if (dayIndex == 3)
                                        Positioned(
                                          top: 150,
                                          left: 5,
                                          right: 5,
                                          height: 100,
                                          child: _buildShiftBlock(
                                            'Deep Clean',
                                            Colors.orange,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftBlock(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
