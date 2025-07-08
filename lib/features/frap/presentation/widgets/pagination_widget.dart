import 'package:flutter/material.dart';
import 'package:bg_med/core/theme/app_theme.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int totalItems;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;
  final Function(int) onItemsPerPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.totalItems,
    required this.itemsPerPage,
    required this.itemsPerPageOptions,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Información de paginación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mostrando ${startIndex + 1}-$endIndex de $totalItems registros',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Por página:',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: itemsPerPage,
                      underline: Container(),
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      items: itemsPerPageOptions.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          onItemsPerPageChanged(newValue);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Controles de paginación
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Primera página
                IconButton(
                  onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                  icon: const Icon(Icons.first_page),
                  tooltip: 'Primera página',
                  color: currentPage > 1 ? AppTheme.primaryGreen : Colors.grey,
                ),
                
                // Botón Página anterior
                IconButton(
                  onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Página anterior',
                  color: currentPage > 1 ? AppTheme.primaryGreen : Colors.grey,
                ),
                
                // Números de página
                ..._buildPageNumbers(),
                
                // Botón Página siguiente
                IconButton(
                  onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Página siguiente',
                  color: currentPage < totalPages ? AppTheme.primaryGreen : Colors.grey,
                ),
                
                // Botón Última página
                IconButton(
                  onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
                  icon: const Icon(Icons.last_page),
                  tooltip: 'Última página',
                  color: currentPage < totalPages ? AppTheme.primaryGreen : Colors.grey,
                ),
              ],
            ),
          ),
          
          // Información adicional
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Página $currentPage de $totalPages',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalPages > 1)
                  Text(
                    'Total: $totalItems registros',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageNumbers = [];
    
    // Determinar qué páginas mostrar
    int start = 1;
    int end = totalPages;
    
    if (totalPages > 7) {
      if (currentPage <= 4) {
        end = 7;
      } else if (currentPage >= totalPages - 3) {
        start = totalPages - 6;
      } else {
        start = currentPage - 3;
        end = currentPage + 3;
      }
    }
    
    // Agregar puntos suspensivos al inicio si es necesario
    if (start > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (start > 2) {
        pageNumbers.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(color: Colors.grey[600])),
          ),
        );
      }
    }
    
    // Agregar números de página
    for (int i = start; i <= end; i++) {
      pageNumbers.add(_buildPageButton(i));
    }
    
    // Agregar puntos suspensivos al final si es necesario
    if (end < totalPages) {
      if (end < totalPages - 1) {
        pageNumbers.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(color: Colors.grey[600])),
          ),
        );
      }
      pageNumbers.add(_buildPageButton(totalPages));
    }
    
    return pageNumbers;
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == currentPage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => onPageChanged(pageNumber),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentPage ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPage ? AppTheme.primaryGreen : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              '$pageNumber',
              style: TextStyle(
                color: isCurrentPage ? Colors.white : Colors.grey[700],
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 