import 'package:flutter/material.dart';
import '../models/destination.dart';

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final double initialHeight;
  final double expandedHeight;
  final VoidCallback? onExplorePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onViewDetails;

  const DestinationCard({
    super.key,
    required this.destination,
    this.initialHeight = 180,
    this.expandedHeight = 320,
    this.onExplorePressed,
    this.onSavePressed,
    this.onViewDetails,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _isExpanded = false;
  bool _showFullDescription = false;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card content with flexible height
            AspectRatio(
              aspectRatio: _isExpanded ? 4 / 5 : 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  _buildImage(),

                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(_isExpanded ? 0.9 : 0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Title and Rating
                        _buildTitleAndRating(
                            textTheme, colorScheme, isSmallScreen),

                        SizedBox(height: isSmallScreen ? 4 : 8),

                        // Location
                        _buildLocation(textTheme),

                        SizedBox(height: isSmallScreen ? 8 : 12),

                        // Features
                        if (widget.destination.features.isNotEmpty &&
                            (!isSmallScreen || _isExpanded))
                          _buildFeatures(textTheme),

                        SizedBox(height: isSmallScreen ? 8 : 12),

                        // Description (expanded only)
                        if (_isExpanded)
                          _buildDescription(textTheme, colorScheme),

                        // Action Buttons
                        Padding(
                          padding: EdgeInsets.only(top: isSmallScreen ? 8 : 12),
                          child: _buildActionButtons(
                              colorScheme, textTheme, isSmallScreen),
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Indicator
                  _buildExpandIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Positioned.fill(
      child: widget.destination.images.isNotEmpty
          ? Image.network(
              widget.destination.images.first,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildTitleAndRating(
      TextTheme textTheme, ColorScheme colorScheme, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            widget.destination.title,
            style:
                (isSmallScreen ? textTheme.titleMedium : textTheme.titleLarge)
                    ?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: _isExpanded ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (widget.destination.averageRating > 0)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 8,
                vertical: isSmallScreen ? 3 : 4),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: isSmallScreen ? 14 : 16,
                  color: Colors.white,
                ),
                SizedBox(width: isSmallScreen ? 2 : 4),
                Text(
                  widget.destination.averageRating.toStringAsFixed(1),
                  style: (isSmallScreen
                          ? textTheme.labelMedium
                          : textTheme.labelLarge)
                      ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocation(TextTheme textTheme) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Colors.white70,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.destination.location,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(TextTheme textTheme) {
    return SizedBox(
      height: 28,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: widget.destination.features
            .take(_isExpanded ? 5 : 3)
            .map(
              (feature) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    feature,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.black.withOpacity(0.4),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDescription(TextTheme textTheme, ColorScheme colorScheme) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.destination.description,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            maxLines: _showFullDescription ? null : 3,
            overflow: _showFullDescription
                ? TextOverflow.clip
                : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () =>
                setState(() => _showFullDescription = !_showFullDescription),
            child: Text(
              _showFullDescription ? 'Show less' : 'Read more',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildActionButtons(
      ColorScheme colorScheme, TextTheme textTheme, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Save button
        IconButton(
          icon: Icon(
            _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: Colors.white.withOpacity(0.8),
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () {
            setState(() => _isSaved = !_isSaved);
            widget.onSavePressed?.call();
          },
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),

        // Explore button - now the only main action button
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: widget.onExplorePressed,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 20,
                    vertical: isSmallScreen ? 8 : 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Explore Now',
                style: (isSmallScreen
                        ? textTheme.labelMedium
                        : textTheme.labelLarge)
                    ?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    final colors = [
      Colors.blue.shade200,
      Colors.red.shade200,
      Colors.green.shade200,
      Colors.orange.shade200,
      Colors.purple.shade200,
    ];
    final color = colors[widget.destination.title.length % colors.length];

    return Container(
      color: color,
      child: Center(
        child: Icon(
          Icons.photo_camera_outlined,
          size: 48,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}
