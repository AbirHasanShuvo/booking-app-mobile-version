import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/service_model.dart';

class ServiceImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double height;
  final double radius;

  const ServiceImage({
    super.key,
    required this.url,
    this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: (url == null || url!.isEmpty)
          ? placeholder
          : CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ServiceImage(url: service.imageUrl, width: 92, height: 92),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.category != null)
                      Text(service.category!.name,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.colorScheme.primary)),
                    Text(service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(service.priceLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary)),
                        const Spacer(),
                        Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(service.durationLabel,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const FeaturedServiceCard({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ServiceImage(url: service.imageUrl, height: 120, width: 220, radius: 0),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(service.priceLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary)),
                        const Spacer(),
                        Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(service.durationLabel,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}