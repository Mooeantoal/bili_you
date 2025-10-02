package dev.aaa1115910.bv.viewmodel.ugc

import dev.aaa1115910.biliapi.entity.ugc.UgcTypeV2
import dev.aaa1115910.biliapi.repositories.UgcRepository
import org.koin.android.annotation.KoinViewModel

@KoinViewModel
class UgcHealthViewModel(
    override val ugcRepository: UgcRepository
) : UgcViewModel(
    ugcRepository = ugcRepository,
    ugcType = UgcTypeV2.Health
)