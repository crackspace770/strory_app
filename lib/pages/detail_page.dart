
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:story_app/data/response/story_response.dart';


class StoriesDetailPage extends StatelessWidget {
  static const routeName = '/detail_page';
  final ListStory? storiesId;
  const StoriesDetailPage ({required this.storiesId, super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(storiesId?.name ?? ''),
      ),
      body: _buildBody(data:storiesId),
    );
  }

  Widget _buildBody({ListStory? data}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 30,
          ),
          Hero(
            tag: data?.id ?? '',
            child: Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    cacheKey: '${data?.photoUrl}',
                    imageUrl: '${data?.photoUrl}',
                    fit: BoxFit.contain,

                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                    // Optional parameters:
                    cacheManager: CacheManager(
                      Config(
                        'photoUrl-cache',
                        stalePeriod: const Duration(days: 7),
                        maxNrOfCacheObjects: 200,
                      ),
                    ),
                    // maxHeightDiskCache: 100,
                    // maxWidthDiskCache: 100,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: Text(
                '${data?.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold
                ),
              ),
            )

          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child:Center(
              child: Text(
                '${data?.description}',
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            )

          ),
          const SizedBox(
            height: 30,
          ),

          const SizedBox(
            height: 10,
          ),

        ],
      ),
    );
  }

}

