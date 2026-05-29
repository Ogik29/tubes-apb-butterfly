<?php

namespace Database\Seeders;

use App\Models\Butterfly;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class ButterflySeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Menggunakan 100 spesies dari dataset gpiosenka/butterfly-images40-species
     */
    public function run(): void
    {
        // 20 spesies beracun dengan detail dari model AI
        $toxicSpecies = [
            'MONARCH' => [
                'toxin' => 'Glikosida jantung',
                'desc' => 'Mengandung toksin glikosida jantung dari tanaman milkweed. Sangat beracun bagi predator.'
            ],
            'ATALA' => [
                'toxin' => 'Cycasin',
                'desc' => 'Mengandung toksin cycasin yang didapat dari tanaman cycad saat fase larva.'
            ],
            'PIPEVINE SWALLOW' => [
                'toxin' => 'Asam aristolochic',
                'desc' => 'Mengandung asam aristolochic dari tanaman pipevine yang dikonsumsi ulatnya.'
            ],
            'BLUE SPOTTED CROW' => [
                'toxin' => 'Toksin tanaman inang',
                'desc' => 'Memiliki toksin dari tanaman inangnya, melindunginya dari predator.'
            ],
            'GREAT EGGFLY' => [
                'toxin' => 'Mimetik',
                'desc' => 'Mimetik spesies beracun. Meniru penampilan kupu-kupu beracun untuk pertahanan.'
            ],
            'DANAID EGGFLY' => [
                'toxin' => 'Mimetik',
                'desc' => 'Mimetik Monarch. Berpura-pura menjadi Monarch yang beracun agar tidak dimangsa.'
            ],
            'VICEROY' => [
                'toxin' => 'Mimikri Batesian',
                'desc' => 'Melakukan mimikri Batesian terhadap Monarch. Memiliki rasa tidak enak bagi predator.'
            ],
            'JULIA' => [
                'toxin' => 'Toksik ringan',
                'desc' => 'Anggota grup Heliconius yang memiliki tingkat toksisitas ringan.'
            ],
            'MALACHITE' => [
                'toxin' => 'Zat kimia pekat',
                'desc' => 'Memiliki zat kimia defensif berbau pekat untuk mengusir predator.'
            ],
            'RED CRACKER' => [
                'toxin' => 'Aposematism',
                'desc' => 'Menggunakan pola warna peringatan (aposematism) untuk menandakan bahaya.'
            ],
            'CAIRNS BIRDWING' => [
                'toxin' => 'Toksin ringan',
                'desc' => 'Memiliki toksin ringan yang cukup untuk memberikan rasa tidak enak bagi burung pemangsa.'
            ],
            'ZEBRA LONG WING' => [
                'toxin' => 'Cyanogenic glycoside',
                'desc' => 'Mengakumulasi toksin dari mengonsumsi serbuk sari tanaman beracun.'
            ],
            'RED POSTMAN' => [
                'toxin' => 'Cyanogenic glycoside',
                'desc' => 'Kupu-kupu Heliconius yang menghasilkan cyanogenic glycoside berbahaya.'
            ],
            'STRAITED QUEEN' => [
                'toxin' => 'Glikosida jantung',
                'desc' => 'Kerabat Monarch dengan mekanisme toksin serupa dari tanaman asalnya.'
            ],
            'SIXSPOT BURNET MOTH' => [
                'toxin' => 'Sianida',
                'desc' => 'Ngengat ini sangat beracun dan dapat mensintesis serta menyimpan hidrogen sianida.'
            ],
            'CINNABAR MOTH' => [
                'toxin' => 'Alkaloid pyrrolizidine',
                'desc' => 'Beracun akibat penumpukan alkaloid pyrrolizidine dari ragwort.'
            ],
            'GARDEN TIGER MOTH' => [
                'toxin' => 'Toksin tanaman',
                'desc' => 'Menggunakan pertahanan toksin tanaman inang yang dikonsumsi saat ulat.'
            ],
            'ROSY MAPLE MOTH' => [
                'toxin' => 'Warna peringatan',
                'desc' => 'Warna peringatan kuat kuning-merah jambu. Ulatnya memiliki bulu yang dapat menyengat.'
            ],
            'IO MOTH' => [
                'toxin' => 'Racun duri (larva)',
                'desc' => 'Memiliki duri (spine) beracun saat fase larva yang dapat menyebabkan reaksi kulit yang sangat menyakitkan.'
            ],
            'BANDED TIGER MOTH' => [
                'toxin' => 'Alkaloid pahit',
                'desc' => 'Memiliki alkaloid defensif yang membuatnya terasa sangat pahit dan dihindari predator.'
            ],
        ];

        // 80 spesies non-toxic lainnya dari dataset
        $otherSpecies = [
            'ADONIS', 'AFRICAN GIANT SWALLOWTAIL', 'AMERICAN SNOOT', 'AN 88', 'APPOLLO', 
            'BANDED PEACOCK', 'BECKERS WHITE', 'BIRD CHERRY ERMINE MOTH', 'BLACK HAIRSTREAK', 'BLUE MORPHO',
            'BROWN SIPROETA', 'CABBAGE WHITE', 'CHALK HILL BLUE', 'CHESTNUT', 'CLEARWING MOTH',
            'CLEOPATRA', 'CLOUDED SULPHUR', 'COMET MOTH', 'COMMON BANDED AWL', 'COMMON BUCKEYE',
            'COMMON WOOD-NYMPH', 'COPPER TAIL', 'CRECENT', 'CRIMSON PATCH', 'EASTERN COMA',
            'EASTERN DAPPLE WHITE', 'EASTERN PINE ELFIN', 'ELBOWED PIERROT', 'EMPEROR MOTH', 'GIANT SWALLOWTAIL',
            'GLASSWING', 'GOLD BANDED', 'GREY HAIRSTREAK', 'HERCULES MOTH', 'HUMMING BIRD HAWK MOTH',
            'INDRA SWALLOW', 'IPHICLUS SISTER', 'LARGE MARBLE', 'LUNA MOTH', 'MADAGASCAN SUNSET MOTH',
            'MANGROVE SKIPPER', 'MEADOW BROWN', 'MOURNING CLOAK', 'OLEANDER HAWK MOTH', 'ORANGE OAKLEAF',
            'ORANGE TIP', 'ORCHARD SWALLOW', 'PAINTED LADY', 'PAPER KITE', 'PEACOCK',
            'PEPPERED MOTH', 'PINE WHITE', 'POLYPHEMUS MOTH', 'POPINJAY', 'PROMETHEA MOTH',
            'PURPLE HAIRSTREAK', 'PURPLISH COPPER', 'QUESTION MARK', 'RED ADMIRAL', 'RED SPOTTED PURPLE',
            'SCARCE SWALLOW', 'SILVER SPOT SKIPPER', 'SLEEPY ORANGE', 'SOOTYWING', 'SOUTHERN DOGFACE',
            'TWO BARRED FLASHER', 'ULYSSES', 'WHITE ERMINE MOTH', 'WOOD SATYR', 'YELLOW SWALLOW TAIL',
            'AFRICAN MOON MOTH', 'ATLAS MOTH', 'BANDED ORANGE HELICONIAN', 'CAMEBERWELL BEAUTY', 'CHECKERED SKIPPER',
            'COMMON CROW', 'COMMON GRASS YELLOW', 'COMMON MORMON', 'DEATHS HEAD HAWK MOTH', 'ELEPHANT HAWK MOTH'
        ];

        $allButterflies = [];

        // Gabungkan spesies beracun
        foreach ($toxicSpecies as $name => $data) {
            $allButterflies[] = [
                'name' => Str::title(strtolower($name)),
                'scientific_name' => 'Spesies ' . Str::title(strtolower($name)),
                'is_toxic' => true,
                'description' => $data['desc'],
                'image_url' => null,
                'habitat' => 'Berbagai habitat',
                'distribution' => 'Global',
                'wing_span' => 'Bervariasi',
                'toxin_type' => $data['toxin'],
                'safety_advice' => '⚠️ PERINGATAN: Kupu-kupu/ngengat ini beracun atau memiliki zat pertahanan berbahaya. Hindari menyentuh secara langsung. Jika terjadi kontak, segera cuci tangan menggunakan sabun dan air mengalir. Jangan pernah mengonsumsi bagian apa pun dari hewan ini. Jika tertelan atau muncul gejala alergi, segera hubungi pertolongan medis.',
                'conservation_status' => 'Unknown',
                'diet' => 'Nektar / Daun inang',
            ];
        }

        // Gabungkan spesies aman
        foreach ($otherSpecies as $name) {
            $allButterflies[] = [
                'name' => Str::title(strtolower($name)),
                'scientific_name' => 'Spesies ' . Str::title(strtolower($name)),
                'is_toxic' => false,
                'description' => 'Kupu-kupu ini tidak beracun dan aman bagi manusia. Memiliki corak dan warna yang menarik untuk berkamuflase atau menarik pasangan.',
                'image_url' => null,
                'habitat' => 'Hutan, taman, padang rumput',
                'distribution' => 'Global',
                'wing_span' => 'Bervariasi',
                'toxin_type' => null,
                'safety_advice' => '✅ Aman: Spesies ini tidak beracun. Anda dapat mengamatinya dari dekat. Namun, tetap jaga jarak aman agar tidak merusak sayapnya yang rapuh.',
                'conservation_status' => 'Unknown',
                'diet' => 'Nektar bunga',
            ];
        }

        // Urutkan berdasarkan nama agar rapi (opsional)
        usort($allButterflies, function($a, $b) {
            return strcmp($a['name'], $b['name']);
        });

        // Hapus data lama agar tidak duplikat saat di seed ulang
        Butterfly::truncate();

        // Insert ke database
        foreach ($allButterflies as $data) {
            Butterfly::create($data);
        }
    }
}
