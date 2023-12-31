import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peliculas/providers/movies_provider.dart';

import '../models/models.dart';

class CastingCards extends StatelessWidget {
  const CastingCards({super.key, required this.movieID});

  final int movieID;

  @override
  Widget build(BuildContext context) {
    final MoviesProvider provider =
        Provider.of<MoviesProvider>(context, listen: false);

    return FutureBuilder(
        future: provider.getMovieCast(movieID),
        builder: (_, AsyncSnapshot<List<Cast>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 100,
              child: CupertinoActivityIndicator(),
            );
          }

          final List<Cast> cast = snapshot.data!;

          return Container(
            margin: const EdgeInsets.only(bottom: 30),
            width: double.infinity,
            height: 180,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length,
                itemBuilder: ((_, index) => _CastCard(
                      actor: cast[index],
                    ))),
          );
        });
  }
}

class _CastCard extends StatelessWidget {
  const _CastCard({super.key, required this.actor});

  final Cast actor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: 100,
      height: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              placeholder: const AssetImage('assets/loading.gif'),
              image: NetworkImage(actor.fullProfilePath),
              fit: BoxFit.cover,
              height: 120,
              width: 100,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            actor.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
