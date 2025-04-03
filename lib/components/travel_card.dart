import 'package:flutter/material.dart';
import '../models/destination.dart';

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final double initialHeight;
  final double expandedHeight;
  final VoidCallback? onExplorePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onViewDetails; // Add this parameter

  const DestinationCard({
    super.key,
    required this.destination,
    this.initialHeight = 180,
    this.expandedHeight = 320,
    this.onExplorePressed,
    this.onSavePressed,
    this.onViewDetails, // Add this
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

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isExpanded ? widget.expandedHeight : widget.initialHeight,
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
          child: Stack(
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Title and Rating
                    _buildTitleAndRating(textTheme, colorScheme),

                    const SizedBox(height: 8),

                    // Location
                    _buildLocation(textTheme),

                    const SizedBox(height: 12),

                    // Features
                    if (widget.destination.features.isNotEmpty)
                      _buildFeatures(textTheme),

                    const SizedBox(height: 12),

                    // Description (expanded only)
                    if (_isExpanded) _buildDescription(textTheme, colorScheme),

                    // Action Buttons
                    _buildActionButtons(colorScheme, textTheme),

                    // View Details Button (expanded only)
                    if (_isExpanded) _buildViewDetailsButton(),
                  ],
                ),
              ),

              // Expand/Collapse Indicator
              _buildExpandIndicator(),
            ],
          ),
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

  Widget _buildTitleAndRating(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            widget.destination.title,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: _isExpanded ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        if (widget.destination.averageRating > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.destination.averageRating.toStringAsFixed(1),
                  style: textTheme.labelLarge?.copyWith(
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
            .take(3)
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
          overflow:
              _showFullDescription ? TextOverflow.clip : TextOverflow.ellipsis,
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
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Save button
        IconButton(
          icon: Icon(
            _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: Colors.white.withOpacity(0.8),
          ),
          onPressed: () {
            setState(() => _isSaved = !_isSaved);
            widget.onSavePressed?.call();
          },
        ),

        // Explore button
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: widget.onExplorePressed,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Explore Now',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewDetailsButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ElevatedButton.icon(
          onPressed: widget.onViewDetails,
          icon: const Icon(Icons.visibility),
          label: const Text('View Details'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
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
