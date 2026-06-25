import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:clocky/models/project.dart';
import 'package:clocky/providers/project_provider.dart';
import 'package:clocky/providers/settings_provider.dart';
import 'package:clocky/theme/app_theme.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = context.watch<ProjectProvider>().projects;
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projekte',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: projects.isEmpty
          ? _buildEmpty(primaryText, secondaryText)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final project = projects[i];
                return _ProjectCard(project: project);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProjectForm(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmpty(Color primaryText, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: AppColors.textSecondaryDark.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Projekte',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Erstelle dein erstes Projekt.',
            style: GoogleFonts.dmSans(fontSize: 14, color: secondaryText),
          ),
        ],
      ),
    );
  }

  void _showProjectForm(BuildContext context, {Project? project}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ProjectForm(project: project),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight;
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Dismissible(
      key: Key('project_${project.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Projekt löschen?'),
            content: Text(
              'Möchtest du „${project.name}" wirklich löschen? '
              'Die zugehörigen Zeiteinträge bleiben erhalten.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Löschen',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<ProjectProvider>().deleteProject(project.id!);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => _ProjectForm(project: project),
            ),
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Colored left bar
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: project.colorValue,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16)),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                  ),
                                ),
                                if (project.clientName != null &&
                                    project.clientName!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    project.clientName!,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: secondaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Hourly rate
                          if (project.hourlyRate > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${project.hourlyRate.toStringAsFixed(0)} €/h',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Edit chevron
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondaryDark,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Project Form Bottom Sheet ────────────────────────────────────────────────

class _ProjectForm extends StatefulWidget {
  final Project? project;

  const _ProjectForm({this.project});

  @override
  State<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<_ProjectForm> {
  late TextEditingController _nameController;
  late TextEditingController _clientNameController;
  late TextEditingController _clientAddressController;
  late TextEditingController _clientEmailController;
  late TextEditingController _rateController;
  late String _selectedColor;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameController = TextEditingController(text: p?.name ?? '');
    _clientNameController = TextEditingController(text: p?.clientName ?? '');
    _clientAddressController = TextEditingController(text: p?.clientAddress ?? '');
    _clientEmailController = TextEditingController(text: p?.clientEmail ?? '');
    _rateController =
        TextEditingController(text: p?.hourlyRate != null && p!.hourlyRate > 0
            ? p.hourlyRate.toString()
            : '');
    _selectedColor = p?.color ?? Project.presetColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientNameController.dispose();
    _clientAddressController.dispose();
    _clientEmailController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = context.read<SettingsProvider>();
    final provider = context.read<ProjectProvider>();

    final project = Project(
      id: widget.project?.id,
      name: _nameController.text.trim(),
      clientName: _clientNameController.text.trim().isNotEmpty
          ? _clientNameController.text.trim()
          : null,
      clientAddress: _clientAddressController.text.trim().isNotEmpty
          ? _clientAddressController.text.trim()
          : null,
      clientEmail: _clientEmailController.text.trim().isNotEmpty
          ? _clientEmailController.text.trim()
          : null,
      hourlyRate: double.tryParse(_rateController.text) ??
          settings.defaultRate,
      color: _selectedColor,
      createdAt: widget.project?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (widget.project == null) {
      await provider.addProject(project);
    } else {
      await provider.updateProject(project);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      color: sheetBg,
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.project == null ? 'Neues Projekt' : 'Projekt bearbeiten',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 20),

              // Project name
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.dmSans(color: primaryText),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Pflichtfeld' : null,
                decoration: const InputDecoration(
                  labelText: 'Projektname *',
                  prefixIcon: Icon(Icons.folder_rounded,
                      size: 18, color: AppColors.primaryOrange),
                ),
              ),
              const SizedBox(height: 12),

              // Client name
              TextFormField(
                controller: _clientNameController,
                style: GoogleFonts.dmSans(color: primaryText),
                decoration: const InputDecoration(
                  labelText: 'Kundenname',
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      size: 18, color: AppColors.primaryOrange),
                ),
              ),
              const SizedBox(height: 12),

              // Client address
              TextFormField(
                controller: _clientAddressController,
                style: GoogleFonts.dmSans(color: primaryText),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Kundenadresse',
                  prefixIcon: Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.primaryOrange),
                ),
              ),
              const SizedBox(height: 12),

              // Client email
              TextFormField(
                controller: _clientEmailController,
                style: GoogleFonts.dmSans(color: primaryText),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Kunden-Email',
                  prefixIcon: Icon(Icons.email_outlined,
                      size: 18, color: AppColors.primaryOrange),
                ),
              ),
              const SizedBox(height: 12),

              // Hourly rate
              TextFormField(
                controller: _rateController,
                style: GoogleFonts.dmSans(color: primaryText),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Stundensatz (€)',
                  prefixIcon: Icon(Icons.euro_rounded,
                      size: 18, color: AppColors.primaryOrange),
                ),
              ),
              const SizedBox(height: 20),

              // Color picker
              Text(
                'Farbe',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: Project.presetColors.map((colorHex) {
                  final hex = colorHex.replaceFirst('#', '');
                  final color = Color(int.parse('FF$hex', radix: 16));
                  final isSelected = _selectedColor == colorHex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorHex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                    widget.project == null
                        ? 'Projekt erstellen'
                        : 'Änderungen speichern',
                    style:
                        GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
